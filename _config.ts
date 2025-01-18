import lume from "lume/mod.ts";
import jsx from "lume/plugins/jsx.ts";
import favicon from "lume/plugins/favicon.ts";

const site = lume({
  src: "./src",
});

site.copy("/styles.css");

site.use(jsx());
site.use(favicon({
  input: "/assets/icon.png",
}));

export default site;
