import {
  Box,
  Chip,
  CircularProgress,
  IconButton,
  Typography,
} from "@material-ui/core";
import { CardContent } from "@material-ui/core";
import { Card } from "@material-ui/core";
import { Tabs, Grid, Tab } from "@material-ui/core";

import React, { useEffect, useState } from "react";
import TemplateFrontmatterProps from "../models/template_frontmatter";
import PageNotFoundPage from "../pages/404";
import Code from "./Code";
import CustomIframe from "./CustomIframe";
import PackagesUsed from "./PackagesUsed";

function TemplateDetailPage(params: TemplateFrontmatterProps) {
  return (
    <div>
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
      <Grid
        item
        md={6}
        style={{
          height: "90vh",
          width: "100%",
        }}
      >
        <Card elevation={0}>
          <CardContent>
            <Grid
              container
              direction="row"
              justifyContent="space-between"
              alignItems="center"
            >
              <Grid item>
                <Typography
                  component="h5"
                  variant="h5"
                  style={{
                    fontWeight: "bold",
                  }}
                >
                  {props.title}
                </Typography>
              </Grid>
            </Grid>
          </CardContent>

          <Tabs
            value={selectedTab}
            onChange={handleTabChange}
            indicatorColor="primary"
            textColor="primary"
            centered
          >
            {/* <Tab label="Info" /> */}
            <Tab label="Code" />
            <Tab label="Packages Used" />
          </Tabs>
        </Card>
        {renderTabs(selectedTab)}
      </Grid>

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
            width: "45vh",
          }}
        >
          <CustomIframe url={props.demoUrl} />
        </div>
      </Grid>
    </Grid>
  );
}

export default TemplateDetailPage;
