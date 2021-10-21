import { Typography } from "@material-ui/core";
import { Card } from "@material-ui/core";
import { Tabs, Grid, Tab } from "@material-ui/core";

import React, { useEffect, useState } from "react";
import TemplateFrontmatterProps from "@/models/template_frontmatter";
import PageNotFoundPage from "@/pages/404";
import CategoriesList from "./CategoriesList";
import Code from "./Code";
import CustomIframe from "./CustomIframe";
import PackagesUsed from "./PackagesUsed";
import TemplatePageHead from "@/head/TemplatePageHead";
import { useRouter } from "next/dist/client/router";
import TemplateCardProps from "@/models/template_card";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import rehypeRaw from "rehype-raw";

function TemplateDetailPage(params: TemplateCardProps) {
  return (
    <div>
      <TemplatePageHead
        title={params.frontmatter.title}
        image={`https://fluttertemplates.dev/${params.frontmatter.image}`}
        id={params.id}
      />
      <RenderBody {...params} />
    </div>
  );
}

function RenderBody(props: TemplateCardProps) {
  const router = useRouter();

  const [selectedTab, setSelectedTab] = useState(0);
  const handleTabChange = (event: any, newValue: any) => {
    setSelectedTab(newValue);
  };

  const _frontmatter = props.frontmatter;
  const _hasMdContent = props.content.toString().length != 0;

  function renderTabs(selectedTab: number) {
    if (_hasMdContent && selectedTab == 0) {
      return (
        <div
          style={{
            width: "100%",
            height: "80%",
            overflowX: "hidden",
            overflowY: "auto",
          }}
        >
          <ReactMarkdown
            children={props.content}
            remarkPlugins={[remarkGfm]}
            rehypePlugins={[rehypeRaw]}
            linkTarget="_blank"
            components={{
              img: ({ node, ...props }) => (
                <img {...props} width="100%" height="100%" />
              ),

              tr: ({ node, ...props }) => (
                <Grid container spacing={1}>
                  {props.children}
                </Grid>
              ),
              td: ({ node, ...props }) => (
                <Grid item xs={4}>
                  {props.children}
                </Grid>
              ),
            }}
          />
        </div>
      );
    } else if (
      (!_hasMdContent && selectedTab == 0) ||
      (_hasMdContent && selectedTab == 1)
    ) {
      return (
        <Code
          codeGistUrl={_frontmatter.codeGistUrl}
          fullCodeUrl={_frontmatter.codeUrl}
        />
      );
    } else if (
      (!_hasMdContent && selectedTab == 1) ||
      (_hasMdContent && selectedTab == 2)
    ) {
      return <PackagesUsed packages={_frontmatter.packages ?? []} />;
    } else {
      return <PageNotFoundPage />;
    }
  }

  return (
    <Grid
      container
      style={{
        marginTop: "2rem",
      }}
      spacing={2}
      justifyContent="center"
    >
      {!(_frontmatter.isProtected ?? false) && (
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
              {_frontmatter.title}
            </Typography>
            {_frontmatter.categories && _frontmatter.categories.length > 0 && (
              <div
                style={{
                  marginLeft: "1rem",
                  marginBottom: "-10px",
                }}
              >
                <CategoriesList
                  categories={_frontmatter.categories}
                  selected={""}
                  showAll={false}
                />
              </div>
            )}

            <Tabs
              value={selectedTab}
              onChange={handleTabChange}
              indicatorColor="secondary"
              textColor="secondary"
              centered
            >
              {_hasMdContent && <Tab label="About" />}
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
          <CustomIframe url={_frontmatter.demoUrl} />
        </div>
      </Grid>
    </Grid>
  );
}

export default TemplateDetailPage;
