import Head from "next/head";

interface HomePageHeadProps {
  title?: string;
}

export default function HomePageHead(props: HomePageHeadProps) {
  return (
    <Head>
      <title>{props.title ?? "Download Free Flutter UI templates"}</title>
      <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0, shrink-to-fit=no"
      />
      <meta property="og:image" content="images/og.png" />
      <meta property="og:type" content="" />
      <meta
        name="twitter:description"
        content={
          props.title ??
          "Download Free Flutter UI Templates for Android, iOS and Web."
        }
      />
      <meta
        name="description"
        content={
          props.title ??
          "Download Free Flutter UI Templates for Android, iOS and Web."
        }
      />
      <meta
        name="title"
        content={props.title ?? "Download Free Flutter UI Templates"}
      />
      <meta
        name="twitter:title"
        content={props.title ?? "Download Free Flutter UI Templates"}
      />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:image" content="images/og.png" />
    </Head>
  );
}
