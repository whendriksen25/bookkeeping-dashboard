import { useEffect, useState } from "react";

const REMOTE_PATTERN = /^https?:\/\//i;

function usePreviewAsset(sourceUrl) {
  const [asset, setAsset] = useState({ url: sourceUrl || "", mime: null });

  useEffect(() => {
    let cancelled = false;
    let objectUrl = null;

    if (!sourceUrl) {
      setAsset({ url: "", mime: null });
      return () => {
        cancelled = true;
        if (objectUrl) URL.revokeObjectURL(objectUrl);
      };
    }

    const isDirect =
      sourceUrl.startsWith("data:") || sourceUrl.startsWith("blob:") || !REMOTE_PATTERN.test(sourceUrl);

    if (isDirect) {
      setAsset({ url: sourceUrl, mime: null });
      return () => {
        cancelled = true;
        if (objectUrl) URL.revokeObjectURL(objectUrl);
      };
    }

    let active = true;
    setAsset({ url: sourceUrl, mime: null });

    (async () => {
      try {
        const response = await fetch(sourceUrl, { credentials: "include" });
        if (!response.ok) {
          throw new Error(`Failed preview fetch: ${response.status}`);
        }
        const blob = await response.blob();
        if (!active || cancelled) return;
        objectUrl = URL.createObjectURL(blob);
        setAsset({ url: objectUrl, mime: blob.type || null });
      } catch (err) {
        if (!cancelled) {
          setAsset({ url: sourceUrl, mime: null });
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
