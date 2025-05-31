import rss from "@astrojs/rss";
import { getCollection } from "astro:content";
import { SITE_TITLE, SITE_DESCRIPTION } from "../consts";

export async function GET(context) {
  const widgets = await getCollection("widgets");
  const blogs = await getCollection("blog");
  const items = [...widgets, ...blogs]
    .map((item) => ({
      ...item.data,
      link: `/${item.collection}/${item.id}/`,
      pubDate: item.data.pubDate || item.data.date || new Date(),
    }))
    .sort((a, b) => new Date(b.pubDate) - new Date(a.pubDate));

  return rss({
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    site: context.site,
    items,
  });
}
