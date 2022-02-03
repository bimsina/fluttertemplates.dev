import SEOHead from "./SEOHead";

interface Props {
  title: string;
  image: string;
  id: string;
}
export default function TemplatePageHead(params: Props) {
  const _title = `${params.title} : Download free Flutter UI Templates for Android, iOS and Web.`;
  const _desc = `${params.title} : Browse through a list of beautifully designed Flutter UI templates to kickstart your development. Download Free Flutter UI Templates for Android, iOS and Web.`;
  return (
    <SEOHead
      title={_title}
      image={params.image}
      description={_desc}
      url={"https://fluttertemplates.dev/templates/" + params.id + "/"}
    />
  );
}
