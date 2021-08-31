import { Box, Chip, Typography } from "@material-ui/core";
import { CardContent } from "@material-ui/core";
import { Card } from "@material-ui/core";
import { Tabs, Grid, Tab } from "@material-ui/core";

import React, { useEffect, useState } from "react";
import PageNotFoundPage from "../404/404Page";
import Code from "./Code";
import "./DetailPage.css";

function DetailPage() {
  const nums = Array.from(Array(4).keys());

  const [selectedTab, setSelectedTab] = useState(0);

  const handleTabChange = (event: any, newValue: any) => {
    setSelectedTab(newValue);
  };

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
              Flutter Gallery
            </Typography>
            <div
              style={{
                marginTop: "8px",
              }}
            >
              <Grid container spacing={1}>
                {nums.map((val) => {
                  return (
                    <Grid item key={val}>
                      <Chip
                        label={"Chip " + val}
                        component="a"
                        color="default"
                        variant="outlined"
                        clickable
                      />
                    </Grid>
                  );
                })}
              </Grid>
            </div>
          </CardContent>

          <Tabs
            value={selectedTab}
            onChange={handleTabChange}
            indicatorColor="primary"
            textColor="primary"
            centered
          >
            <Tab label="Info" />
            <Tab label="Code" />
            <Tab label="Reviews" />
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
          <iframe
            src="https://gallery.flutter.dev/"
            style={{
              height: "100%",
              width: "100%",
              borderRadius: "1rem",
            }}
          ></iframe>
        </div>
      </Grid>
    </Grid>
  );
}

function renderTabs(selectedTab: number) {
  switch (selectedTab) {
    case 0:
      return <PageNotFoundPage />;
    case 1:
      return (
        <Code url="https://raw.githubusercontent.com/bimsina/GuessTheCelebrity/master/app/src/main/java/com/example/bimsina/guessthecelebrity/MainActivity.java" />
      );
    case 2:
      return <PageNotFoundPage />;
    default:
      return <PageNotFoundPage />;
  }
}

export default DetailPage;
