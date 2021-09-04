import { Container, Grid, Typography } from "@material-ui/core";
import React from "react";
import TemplateCardProps from "../models/template_card";
import CategoriesList from "./CategoriesList";
import CustomButton from "./custom_button";
import TemplateCard from "./TemplateCard";

export default function TemplatesGrid({
  templates,
  limit,
}: {
  templates: TemplateCardProps[];
  limit: boolean;
}) {
  const [selectedCategory, setSelectedCategory] = React.useState("all");
  const [categories, setCategories] = React.useState<string[]>([]);

  const [filteredTemplates, setFilteredTemplates] = React.useState(
    templates.slice(0, limit ? 12 : templates.length)
  );

  React.useEffect(() => {
    setCategories(reduceTemplates(templates));
    if (selectedCategory === "all") {
      setFilteredTemplates(templates.slice(0, limit ? 12 : templates.length));
    } else {
      const _filtered = templates.filter((val) => {
        if (val.frontmatter.categories.includes(selectedCategory)) {
          return true;
        } else return false;
      });
      setFilteredTemplates(_filtered.slice(0, limit ? 12 : _filtered.length));
    }
  }, [selectedCategory]);

  return (
    <Container
      style={{
        marginBottom: "2.5rem",
      }}
    >
      <Typography
        variant="h5"
        style={{
          fontWeight: "bold",
          marginTop: "2rem",
        }}
      >
        All Templates
      </Typography>

      <CategoriesList
        categories={categories}
        onChange={(category) => {
          setSelectedCategory(category);
        }}
        selected={selectedCategory}
      />

      {filteredTemplates.length === 0 ? (
        <Grid
          container
          direction="column"
          justifyContent="center"
          alignItems="center"
          spacing={4}
          style={{
            width: "100%",
            marginTop: "2rem",
            marginBottom: "2rem",
          }}
        >
          <Grid item>
            <img
              src="/404.svg"
              style={{
                height: "30vh",
              }}
            />
          </Grid>
          <Grid item>
            <Typography>No Templates found</Typography>
          </Grid>
        </Grid>
      ) : (
        <Grid container>
          {filteredTemplates.map(
            (template: TemplateCardProps, index: number) => {
              return (
                <TemplateCard
                  key={index}
                  id={template.id}
                  frontmatter={template.frontmatter}
                />
              );
            }
          )}
        </Grid>
      )}

      {limit && (
        <Grid
          container
          direction="row"
          justifyContent="center"
          alignItems="center"
        >
          <Grid item>
            <CustomButton variant="contained" color="primary">
              Browse All Templates
            </CustomButton>
          </Grid>
        </Grid>
      )}
    </Container>
  );

  function reduceTemplates(templates: TemplateCardProps[]): string[] {
    let _return: string[] = [];
    templates.forEach((template: TemplateCardProps) => {
      _return.push(...template.frontmatter.categories);
    });
    return Array.from(new Set(_return));
  }
}
