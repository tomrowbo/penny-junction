const emailPattern = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/gi;
const ibanPattern = /\b[A-Z]{2}\d{2}(?:\s?[A-Z0-9]){11,30}\b/gi;
const phonePattern = /(?<!\w)(?:\+\d{1,3}[\s.-]?)?(?:\d[\s.-]?){7,14}\d(?!\w)/g;
const isoDatePattern = /\b\d{4}-\d{2}-\d{2}\b/g;

function validISODate(value: string): boolean {
  const parsed = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(parsed.getTime()) && parsed.toISOString().slice(0, 10) === value;
}

export function redactPII(text: string): string {
  const dates: string[] = [];
  const protectedText = text.replace(isoDatePattern, (value) => {
    if (!validISODate(value)) return value;
    const token = `__PENNYDATE${dates.length}__`;
    dates.push(value);
    return token;
  });
  return protectedText
    .replace(emailPattern, "[email redacted]")
    .replace(ibanPattern, "[account number redacted]")
    .replace(phonePattern, "[phone number redacted]")
    .replace(/__PENNYDATE(\d+)__/g, (_, index: string) => dates[Number(index)] ?? "[date]");
}
