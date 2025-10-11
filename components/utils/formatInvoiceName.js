function formatInvoiceName({ vendor, invoiceDate, invoiceNumber, fallback = "Invoice" }) {
  const parts = [];
  const vendorName = vendor ? String(vendor).trim() : "";
  if (vendorName) parts.push(vendorName);

  let normalizedDate = "";
  if (invoiceDate) {
    const parsed = new Date(invoiceDate);
    if (!Number.isNaN(parsed.getTime())) {
      normalizedDate = parsed.toISOString().slice(0, 10);
    } else if (typeof invoiceDate === "string" && invoiceDate.trim()) {
      normalizedDate = invoiceDate.trim();
    }
  }
  if (normalizedDate) parts.push(normalizedDate);

  const numberLabel = invoiceNumber ? String(invoiceNumber).trim() : "";
  if (numberLabel) parts.push(`#${numberLabel}`);

  if (!parts.length) return fallback;
  return parts.join(" · ");
}

export default formatInvoiceName;
