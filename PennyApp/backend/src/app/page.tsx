export default function Home() {
  return (
    <main style={{ fontFamily: "system-ui", maxWidth: 720, margin: "64px auto", padding: 24 }}>
      <h1>Penny API</h1>
      <p>The S-mobiili concept backend is running.</p>
      <p><a href="/api/health">Check API health</a></p>
    </main>
  );
}
