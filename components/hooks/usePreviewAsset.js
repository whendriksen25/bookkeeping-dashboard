import { useEffect, useState } from "react";

const REMOTE_PATTERN = /^https?:\/\//i;

function usePreviewAsset(sourceUrl) {
  const [asset, setAsset] = useState({ url: sourceUrl || "", mime: null, unsupported: false, originalUrl: sourceUrl || "" });

  useEffect(() => {
    let cancelled = false;
    let objectUrl = null;

    if (!sourceUrl) {
      setAsset({ url: "", mime: null, unsupported: false, originalUrl: "" });
      return () => {
        cancelled = true;
        if (objectUrl) URL.revokeObjectURL(objectUrl);
      };
    }

    const heicPattern = /\.hei[cf](?:\?.*)?$/i;
    const looksLikeHeic = heicPattern.test(sourceUrl);

    const isDirect =
      sourceUrl.startsWith("data:") || sourceUrl.startsWith("blob:") || !REMOTE_PATTERN.test(sourceUrl);

    if (looksLikeHeic) {
      setAsset({ url: "", mime: "image/heic", unsupported: true, originalUrl: sourceUrl });
      return () => {
        cancelled = true;
        if (objectUrl) URL.revokeObjectURL(objectUrl);
      };
    }

    if (isDirect) {
      setAsset({ url: sourceUrl, mime: null, unsupported: false, originalUrl: sourceUrl });
      return () => {
        cancelled = true;
        if (objectUrl) URL.revokeObjectURL(objectUrl);
      };
    }

    let active = true;
    setAsset({ url: sourceUrl, mime: null, unsupported: false, originalUrl: sourceUrl });

    (async () => {
      try {
        const response = await fetch(sourceUrl);
        if (!response.ok) {
          throw new Error(`Failed preview fetch: ${response.status}`);
        }
        let blob = await response.blob();
        if (!active || cancelled) return;

        const mime = blob.type || "";
        if (/heic|heif/i.test(mime)) {
          setAsset({ url: "", mime: mime || "image/heic", unsupported: true, originalUrl: sourceUrl });
          return;
        }

        if (!active || cancelled) return;
        objectUrl = URL.createObjectURL(blob);
        setAsset({ url: objectUrl, mime: blob.type || null, unsupported: false, originalUrl: sourceUrl });
      } catch (err) {
        if (!cancelled) {
          setAsset({ url: sourceUrl, mime: null, unsupported: false, originalUrl: sourceUrl });
          if (process.env.NODE_ENV !== "production") {
            console.warn("[usePreviewAsset] Falling back to raw URL", err);
          }
        }
      }
    })();

    return () => {
      active = false;
      cancelled = true;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
    };
  }, [sourceUrl]);

  return asset;
}

export default usePreviewAsset;
