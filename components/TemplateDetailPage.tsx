import { Typography } from "@material-ui/core";
import { Card } from "@material-ui/core";
import { Tabs, Grid, Tab } from "@material-ui/core";

import React, { useEffect, useState } from "react";
import TemplateFrontmatterProps from "../models/template_frontmatter";
import PageNotFoundPage from "../pages/404";
import CategoriesList from "./CategoriesList";
import Code from "./Code";
import CustomIframe from "./CustomIframe";
import PackagesUsed from "./PackagesUsed";
import TemplatePageHead from "../head/TemplatePageHead";

function TemplateDetailPage(params: TemplateFrontmatterProps) {
  return (
    <div>
      <TemplatePageHead title={params.title} image={params.image} />
      <RenderBody {...params} />
    </div>
  );
}

function RenderBody(props: TemplateFrontmatterProps) {
  const [selectedTab, setSelectedTab] = useState(0);
  const handleTabChange = (event: any, newValue: any) => {
    setSelectedTab(newValue);
  };

  function renderTabs(selectedTab: number) {
    switch (selectedTab) {
      case 0:
        return (
          <Code codeGistUrl={props.codeGistUrl} fullCodeUrl={props.codeUrl} />
        );
      case 1:
        return <PackagesUsed packages={props.packages ?? []} />;
      default:
        return <PageNotFoundPage />;
    }
  }

  return (
    <Grid
      container
      style={{
        height: "90vh",
        marginTop: "2rem",
      }}
      spacing={2}
      // alignItems="center"
      justifyContent="space-evenly"
    >
      {!(props.isProtected ?? false) && (
        <Grid
          item
          md={6}
          style={{
            height: "90vh",
            width: "100%",
          }}
        >
          <Card elevation={0}>
            <Typography
              component="h5"
              variant="h5"
              style={{
                fontWeight: "bold",
                marginLeft: "1rem",
                marginTop: "1rem",
              }}
            >
              {props.title}
            </Typography>
            {props.categories && props.categories.length > 0 && (
              <div
                style={{
                  marginLeft: "1rem",
                  marginBottom: "-10px",
                }}
              >
                <CategoriesList
                  categories={props.categories}
                  selected={""}
                  onChange={(val) => {}}
                  showAll={false}
                />
              </div>
            )}

            <Tabs
              value={selectedTab}
              onChange={handleTabChange}
              indicatorColor="primary"
              textColor="primary"
              centered
            >
              <Tab label="Code" />
              <Tab label="Packages Used" />
            </Tabs>
          </Card>
          {renderTabs(selectedTab)}
        </Grid>
      )}
      <Grid
        item
        md={6}
        style={{
          display: "flex",
          justifyContent: "center",
        }}
      >
        <div
          style={{
            height: "80vh",
            width: "calc(80vh/17 * 9)",
          }}
        >
          <CustomIframe url={props.demoUrl} />
        </div>
      </Grid>
    </Grid>
  );
}

export default TemplateDetailPage;