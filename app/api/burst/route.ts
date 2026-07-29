export const runtime = "edge";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const requestedMb = Number(url.searchParams.get("mb") ?? 2);
  const megabytes = Math.min(8, Math.max(1, Number.isFinite(requestedMb) ? requestedMb : 2));
  const bytes = Math.floor(megabytes * 1024 * 1024);
  const payload = new Uint8Array(bytes);

  let state = 0x12345678;
  for (let index = 0; index < payload.length; index += 1) {
    state ^= state << 13;
    state ^= state >>> 17;
    state ^= state << 5;
    payload[index] = state & 0xff;
  }

  return new Response(payload, {
    headers: {
      "cache-control": "no-store, no-cache, no-transform",
      "content-type": "application/octet-stream",
      "content-length": String(payload.byteLength),
      "content-disposition": "inline",
      "x-rc-payload-mb": String(megabytes),
    },
  });
}
