export const runtime = "edge";

export async function GET(request: Request) {
  const url = new URL(request.url);
  return Response.json(
    {
      ok: true,
      sequence: Number(url.searchParams.get("sequence") ?? 0),
      serverTime: Date.now(),
    },
    {
      headers: {
        "cache-control": "no-store, no-cache, must-revalidate",
        "server-timing": "rc-pulse;dur=0",
      },
    },
  );
}
