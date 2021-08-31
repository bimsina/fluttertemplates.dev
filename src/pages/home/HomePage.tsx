import React from "react";
import {
  Button,
  Card,
  CardContent,
  CardMedia,
  Chip,
  Grid,
} from "@material-ui/core";
import HeroImage from "../../assets/home_hero.svg";
import { Typography } from "@material-ui/core";
import { Divider } from "@material-ui/core";
import { CardActionArea } from "@material-ui/core";
import CustomButton from "../../components/custom_button";

export default function HomePage() {
  return (
    <div>
      <HeroSection />
      <ProductsList />
    </div>
  );
}

function HeroSection() {
  return (
    <Grid
      container
      justifyContent="center"
      alignItems="center"
      style={{
        // height: "90vh",
        width: "100%",
      }}
    >
      <Grid item md={6}>
        <Grid
          container
          direction="column"
          justifyContent="center"
          alignItems="flex-start"
          spacing={4}
          style={{
            padding: "4rem",
          }}
        >
          <Grid>
            <Typography
              variant="h4"
              style={{
                fontWeight: "bold",
              }}
            >
              Flutter UI Templates
            </Typography>
          </Grid>

          <Grid
            style={{
              marginTop: "2rem",
              marginBottom: "2rem",
            }}
          >
            <Typography>
              Don't you hate it when you pay hundreds of dollars for a flutter
              template which has limited functionalities? Don't worry, we got
              your back. Here you will find a collection of mobile application
              UI templates for Android, iOS and Web, built using Google’s
              Flutter Mobile App SDK. All you need to do is copy-paste our code
              into your flutter app. Easy right?
            </Typography>
          </Grid>

          <Grid>
            <CustomButton
              variant="contained"
              color="primary"
              href="/detail/1234"
              disableElevation
              style={{
                fontSize: "1.1rem",
              }}
            >
              Lets get started!
            </CustomButton>
          </Grid>
        </Grid>
      </Grid>

      <Grid item md={6}>
        <img
          src={HeroImage}
          style={{
            width: "100%",
            maxHeight: "85vh",
            objectFit: "scale-down",
          }}
        />
      </Grid>
    </Grid>
  );
}

function ProductsList() {
  const nums = [
    { id: 1, title: "All" },
    { id: 2, title: "Android" },
    { id: 3, title: "iOS" },
    { id: 4, title: "Web" },
  ];

  return (
    <div
      style={{
        padding: "4rem",
      }}
    >
      <Typography
        variant="h5"
        style={{
          fontWeight: "bold",
        }}
      >
        All Apps
      </Typography>

      <Grid
        container
        spacing={1}
        style={{
          marginTop: "0.5rem",
          marginBottom: "1rem",
        }}
      >
        {nums.map((val) => {
          return (
            <Grid item key={val.id}>
              <Chip
                label={val.title}
                component="a"
                color={nums.indexOf(val) === 0 ? "primary" : "default"}
                variant="default"
                clickable
              />
            </Grid>
          );
        })}
      </Grid>

      <Grid container>
        {nums.map((val) => {
          return (
            <Grid item md={3} xs={12} sm={6} key={val.id}>
              {/* <Skeleton
                variant="rect"
                height="12rem"
                style={{
                  margin: "0.8rem",
                  borderRadius: "0.5rem",
                }}
              /> */}

              <Card
                elevation={0}
                style={{
                  margin: "0.8rem",
                }}
              >
                <CardActionArea
                  onClick={() => (location.href = "/detail/1234")}
                >
                  <CardMedia
                    image="https://www.instamobile.io/wp-content/uploads/2021/06/taxi-app-react-native.png"
                    title={val.title}
                    style={{
                      height: "10rem",
                    }}
                  />
                  <CardContent>
                    <Typography gutterBottom variant="h6" component="h2">
                      {val.title}
                    </Typography>
                  </CardContent>
                </CardActionArea>
              </Card>
            </Grid>
          );
        })}
      </Grid>
    </div>
  );
}
