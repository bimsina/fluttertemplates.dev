import { Container, Grid, Typography } from "@material-ui/core";
import React, { useEffect, useState } from "react";
import TemplateCardProps from "@/models/template_card";
import CategoriesList from "./CategoriesList";
import CustomButton from "./custom_button";
import TemplateCard from "./TemplateCard";

export default function TemplatesGrid({
  templates,
  limit,
  selectedCatId,
}: {
  templates: TemplateCardProps[];
  limit: boolean;
  selectedCatId?: string;
}) {
  const [selectedCategory, setSelectedCategory] = useState(
    selectedCatId ?? "all"
  );
  const [categories, setCategories] = useState<string[]>([]);

  const [filteredTemplates, setFilteredTemplates] = useState(
    templates.slice(0, limit ? 12 : templates.length)
  );

  useEffect(() => {
    if (categories.length === 0) {
      setCategories(reduceTemplates(templates));
    }
    _changeCat();
  }, [selectedCategory]);

  function _changeCat() {
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
  }
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

      {selectedCategory && (
        <CategoriesList
          categories={categories}
          onChange={(category) => {
            setSelectedCategory(category);
          }}
          selected={selectedCategory}
          showAll={true}
        />
      )}

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
            <CustomButton
              variant="contained"
              color="primary"
              href="/templates"
              aria-label="Browse Templates"
            >
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
