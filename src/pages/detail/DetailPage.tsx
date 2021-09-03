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
import { Edit } from "@material-ui/icons";
import { checkifIsAdmin } from "../../utils/isAdmin";

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
        <RenderBody
          product={{
            id: snapshot.id,
            ...(snapshot.data()! as Product),
          }}
        />
      )}
    </div>
  );
}

interface RenderBodyProps {
  product: Product;
}

function RenderBody(props: RenderBodyProps) {
  const [selectedTab, setSelectedTab] = useState(0);
  const handleTabChange = (event: any, newValue: any) => {
    setSelectedTab(newValue);
  };

  function renderTabs(selectedTab: number) {
    switch (selectedTab) {
      case 0:
        if (props.product.codeGistUrl)
          return (
            <Code
              codeGistUrl={props.product.codeGistUrl}
              fullCodeUrl={props.product.codeUrl}
            />
          );
        else return <div />;
      case 1:
        return <PackagesUsed packages={props.product?.packageLinks ?? []} />;
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
                  {props.product.title}
                </Typography>
              </Grid>

              <Grid>
                <EditButton id={props.product.id ?? "id"} />
              </Grid>
            </Grid>

            <TemplateCategories categories={props.product.categories} />
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
          <CustomIframe url={props.product.demoUrl} />
          {/* <iframe
            src={props.product.demoUrl}
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

function EditButton(params: { id: string }) {
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    fetchUser();
  }, []);

  function fetchUser() {
    firebase.auth().onAuthStateChanged(async (_currentUser) => {
      if (_currentUser) {
        const _isAdmin = await checkifIsAdmin(_currentUser.uid);
        setIsAdmin(_isAdmin);
      }
    });
  }

  if (!isAdmin) return <div />;
  else
    return (
      <IconButton size="small" href={`/addTemplates/${params.id}`}>
        <Edit />
      </IconButton>
    );
}

export default DetailPage;
