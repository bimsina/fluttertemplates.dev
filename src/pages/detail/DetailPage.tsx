import { Box, Chip, CircularProgress, Typography } from "@material-ui/core";
import { CardContent } from "@material-ui/core";
import { Card } from "@material-ui/core";
import { Tabs, Grid, Tab } from "@material-ui/core";

import React, { useEffect, useState } from "react";
import { useDocumentOnce } from "react-firebase-hooks/firestore";
import { useParams } from "react-router-dom";
import PageNotFoundPage from "../404/404Page";
import Code from "./Code";
import "./DetailPage.css";
import firebase from "../../firebase/clientApp";
import Product from "../../models/Product";
import CustomIframe from "./CustomIframe";
import TemplateCategories from "./TemplateCategories";
import PackagesUsed from "./PackagesUsed";

function DetailPage() {
  const nums = Array.from(Array(4).keys());

  const data = useParams<{ id: string }>();

  const [snapshot, loading, error] = useDocumentOnce(
    firebase
      .firestore()
      .collection("templates")
      .doc(data["id"] as string)
  );

  return (
    <div>
      {loading && (
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
            <CircularProgress size="1.5rem" thickness={8} />
          </Grid>
        </Grid>
      )}
      {!loading && snapshot?.data() && (
        <RenderBody {...(snapshot.data()! as Product)} />
      )}
    </div>
  );
}

function RenderBody(props: Product) {
  const [selectedTab, setSelectedTab] = useState(0);
  const handleTabChange = (event: any, newValue: any) => {
    setSelectedTab(newValue);
  };

  function renderTabs(selectedTab: number) {
    switch (selectedTab) {
      // case 0:
      //   return <PageNotFoundPage />;
      case 0:
        if (props.codeGistUrl)
          return (
            <Code codeGistUrl={props.codeGistUrl} fullCodeUrl={props.codeUrl} />
          );
        else return <div />;
      case 1:
        return <PackagesUsed packages={props?.packageLinks ?? []} />;
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
            <Typography
              component="h5"
              variant="h5"
              style={{
                fontWeight: "bold",
              }}
            >
              {props.title}
            </Typography>

            <TemplateCategories categories={props.categories} />
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
            aspectRatio: "9 / 16",
          }}
        >
          <CustomIframe url={props.demoUrl} />
          {/* <iframe
            src={props.demoUrl}
            style={{
              height: "100%",
              width: "100%",
              borderRadius: "1rem",
            }}
          ></iframe> */}
        </div>
      </Grid>
    </Grid>
  );
}

export default DetailPage;
