import { defineConfig } from "vite";
import fs from "fs";

export default {
  vite: defineConfig({}),
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/style.css" />
<meta name="generator" content="elm-pages v${context.cliVersion}" />
<meta name="google-site-verification" content="bXaLaMdmF7uQAmi3krHPyj2D-Z6Zos0Jd048QJPqhL8" />
`;
  },
  preloadTagForFile(file) {
    // add preload directives for JS assets and font assets, etc., skip for CSS files
    // this function will be called with each file that is processed by Vite, including any files in your headTagsTemplate in your config
    return !file.endsWith(".css");
  },
  adapter() {
    console.log("Generating 404.html with redirect to ErrorPage.elm...");

    const redirectHtml = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found | 関数型まつり</title>
    <meta http-equiv="refresh" content="0; url=/not-found">
    <script>
        // Redirect to /not-found route that displays ErrorPage.elm content
        window.location.replace('/not-found');
    </script>
</head>
<body>
    <p>Page not found. Redirecting to <a href="/not-found">error page</a>...</p>
</body>
</html>`;

    fs.writeFileSync("dist/404.html", redirectHtml);
    console.log("✅ Generated 404.html with redirect to /not-found route (ErrorPage.elm)");

    return Promise.resolve();
  },
};
