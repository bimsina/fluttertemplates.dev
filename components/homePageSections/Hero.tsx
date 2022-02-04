import { Grid, Typography, useTheme } from "@material-ui/core";
import { ArrowForward } from "@material-ui/icons";
import CustomContainedButton from "../buttons/ContainedButton";
import CustomFlatButton from "../buttons/FlatButton";

function HeroSection(props: any) {
  const theme = useTheme();

  return (
    <Grid
      container
      justifyContent="center"
      alignItems="center"
      style={{
        width: "100%",
      }}
    >
      <Grid item md={7}>
        <Grid
          container
          direction="column"
          justifyContent="center"
          alignItems="flex-start"
          spacing={4}
          style={{
            padding: "2rem",
          }}
        >
          <Grid>
            <Typography
              variant="h1"
              style={{
                fontWeight: "bolder",
                fontSize: "2.4rem",
                color: theme.palette.secondary.main,
              }}
            >
              Production-ready
            </Typography>
            <Typography
              variant="h1"
              style={{
                fontWeight: "bold",
                fontSize: "2.9rem",
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
            <Typography
              variant="h2"
              style={{
                fontSize: "16px",
                lineHeight: "1.4",
              }}
            >
              A collection of production-ready open source Flutter UI Templates
              and Widgets.
            </Typography>
          </Grid>

          <Grid
            container
            spacing={2}
            direction="row"
            justifyContent="flex-start"
            alignItems="center"
          >
            <Grid item>
              <CustomContainedButton
                href="/widgets"
                label="Browse Widgets"
                icon={<ArrowForward fontSize="small" />}
              />
            </Grid>
            <Grid item>
              <CustomFlatButton href="/templates" label="Browse Templates" />
            </Grid>
          </Grid>
        </Grid>
      </Grid>

      <Grid item md={5}>
        <img
          src="/home_hero.svg"
          alt="hero"
          style={{
            width: "100%",
            height: "75vh",
            objectFit: "scale-down",
          }}
        />
      </Grid>
    </Grid>
  );
}
export default HeroSection;
