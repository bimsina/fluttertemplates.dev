import React from "react";
import TemplateCardProps from "@/models/template_card";
import getTemplatesList from "@/utils/getTemplatesList";
import TemplatesGrid from "@/components/TemplatesGrid";
import HomePageHead from "@/head/SEOHead";
import { useRouter } from "next/dist/client/router";
import { CircularProgress, Container, Grid } from "@material-ui/core";

export default function TemplatesList({
  templates,
}: {
  templates: TemplateCardProps[];
}) {
  const router = useRouter();
  const [category, setCategory] = React.useState<string | undefined>();

  const { catId } = router.query;

  React.useEffect(() => {
    getCat();
  }, []);

  function getCat() {
    setTimeout(() => {
      const _cat = (router.query.catId ?? "all").toString();
      setCategory(_cat);
    }, 1000);
  }

  return (
    <Container maxWidth="lg">
      <HomePageHead />
      {!category && (
        <Grid
          container
          direction="column"
          justifyContent="center"
          alignItems="center"
          style={{
            minHeight: "40vh",
          }}
        >
          <Grid item>
            <CircularProgress size="1.5rem" thickness={8} color="secondary" />
          </Grid>
        </Grid>
      )}
      {category && (
        <TemplatesGrid
          templates={templates}
          limit={false}
          selectedCatId={catId as string}
        />
      )}
    </Container>
  );
}

export async function getStaticProps() {
  const _data = getTemplatesList();
  return _data;
}
