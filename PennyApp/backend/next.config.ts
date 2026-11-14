import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  turbopack: { root: process.cwd() },
  outputFileTracingIncludes: {
    "/api/chat": ["./src/data/penny-demo.sqlite"],
    "/api/customer/summary": ["./src/data/penny-demo.sqlite"],
  },
};

export default nextConfig;
