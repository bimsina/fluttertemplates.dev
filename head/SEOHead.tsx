import {
  PRODUCTION_URL,
  SEO_DESCRIPTION,
  SEO_KEYWORDS,
  SEO_OG_IMAGE,
  SEO_TITLE,
} from "../constants";
import { useRouter } from "next/dist/client/router";
import Head from "next/head";

interface SEOHeadProps {
  title?: string;
  image?: string;
  description?: string;
  url?: string;
}

export default function SEOHead(props: SEOHeadProps) {
  const router = useRouter();
  return (
    <Head>
      <title>{props.title ?? SEO_TITLE}</title>
      <meta name="description" content={props.description ?? SEO_DESCRIPTION} />
      <meta name="keywords" content={SEO_KEYWORDS} />
      <meta
        property="og:url"
        content={props.url ?? `${PRODUCTION_URL}${router.asPath}`}
      />
      <meta property="og:type" content="website" />
      <meta property="og:title" content={props.title ?? SEO_TITLE} />
      <meta
        property="og:description"
        content={props.description ?? SEO_DESCRIPTION}
      />
      <meta property="og:image" content={props.image ?? SEO_OG_IMAGE} />
      <meta name="twitter:card" content="summary_large_image" />
      <meta property="twitter:url" content={props.url ?? PRODUCTION_URL} />
      <meta name="twitter:title" content={props.title ?? SEO_TITLE} />
      <meta
        name="twitter:description"
        content={props.description ?? SEO_DESCRIPTION}
      />
      <meta name="twitter:image" content={props.image ?? SEO_OG_IMAGE} />
    </Head>
  );
}
