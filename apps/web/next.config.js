module.exports = {
  reactStrictMode: true,
  transpilePackages: ["ui"],
  output: 'foo'
};

const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["ui"],
  output: 'export',
};
 
module.exports = nextConfig;
