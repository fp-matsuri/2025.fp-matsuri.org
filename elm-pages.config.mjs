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
    try {
      const notFoundPath = "dist/not-found/index.html";
      if (fs.existsSync(notFoundPath)) {
        let notFoundHtml = fs.readFileSync(notFoundPath, 'utf8');
        notFoundHtml = notFoundHtml
          .replace(/<script[^>]*elm\.[\w.]+\.js[^>]*><\/script>/g, '')
          .replace(/<script[^>]*type="module"[^>]*><\/script>/g, '')
          .replace(/<link[^>]*modulepreload[^>]*>/g, '')
          .replace(/<script[^>]*defer[^>]*><\/script>/g, '');

        fs.writeFileSync("dist/404.html", notFoundHtml);
        console.log("✅ Generated 404.html using ErrorPage.elm HTML without JavaScript dependencies");
      } else {
        console.log("⚠️  /not-found route not found, skipping 404.html generation");
      }
    } catch (error) {
      console.error("❌ Error generating 404.html:", error);
    }

    return Promise.resolve();
  },
};
