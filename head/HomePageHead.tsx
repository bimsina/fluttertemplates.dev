import Head from "next/head";

interface HomePageHeadProps {
  title?: string;
}

export default function HomePageHead(props: HomePageHeadProps) {
  return (
    <Head>
      <title>
        {props.title ??
          "Download Free Flutter UI templates for Android, iOS and Web."}
      </title>
      <meta
        name="description"
        content="Browse through a list of beautifully designed Flutter UI templates to kickstart your development. Download Free Flutter UI Templates for Android, iOS and Web."
      />

      <meta property="og:url" content="https://fluttertemplates.dev/" />
      <meta property="og:type" content="website" />
      <meta
        property="og:title"
        content={
          props.title ??
          "Download Free Flutter UI templates for Android, iOS and Web."
        }
      />
      <meta
        property="og:description"
        content="Browse through a list of beautifully designed Flutter UI templates to kickstart your development. Download Free Flutter UI Templates for Android, iOS and Web."
      />
      <meta property="og:image" content="https://fluttertemplates.dev/og.png" />

      <meta name="twitter:card" content="summary_large_image" />
      <meta property="twitter:domain" content="fluttertemplates.dev" />
      <meta property="twitter:url" content="https://fluttertemplates.dev/" />
      <meta
        name="twitter:title"
        content={
          props.title ??
          "Download Free Flutter UI templates for Android, iOS and Web."
        }
      />
      <meta
        name="twitter:description"
        content="Browse through a list of beautifully designed Flutter UI templates to kickstart your development. Download Free Flutter UI Templates for Android, iOS and Web."
      />
      <meta
        name="twitter:image"
        content="https://fluttertemplates.dev/og.png"
      />
    </Head>
  );
}
