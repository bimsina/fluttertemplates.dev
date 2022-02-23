import { AppBar, Grid, IconButton, Typography } from "@mui/material";
import { LinkedIn, MailOutlineRounded, Twitter } from "@mui/icons-material";
import { BUY_ME_A_COFFEE_LINK } from "../../constants";

export default function Footer() {
  return (
    <div>
      <AppBar
        position="static"
        color="primary"
        elevation={0}
        style={{
          padding: "2.5rem",
          width: "100%",
        }}
      >
        <Grid
          container
          spacing={8}
          direction="row"
          justifyContent="center"
          alignItems="center"
        >
          <Grid item>
            <Grid
              container
              direction="column"
              justifyContent="center"
              alignItems="center"
            >
              <Grid item>
                <Typography
                  style={{
                    fontSize: "1rem",
                    fontWeight: "bold",
                  }}
                >
                  Support Us
                </Typography>
              </Grid>

              <Grid item>
                <a
                  href={BUY_ME_A_COFFEE_LINK}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <img
                    src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png"
                    alt="Buy Me A Coffee"
                    style={{
                      marginTop: "1rem",
                      height: "60px !important",
                      width: "217px !important",
                    }}
                  />
                </a>
              </Grid>
            </Grid>
          </Grid>
          <Grid item>
            <Grid
              container
              direction="column"
              justifyContent="center"
              alignItems="center"
            >
              <Grid item>
                <Typography
                  style={{
                    fontSize: "1rem",
                    fontWeight: "bold",
                  }}
                >
                  Contact
                </Typography>
              </Grid>

              <Grid item>
                <div>
                  <IconButton
                    href="mailto:timsinabibek960@gmail.com"
                    target="_blank"
                    referrerPolicy="no-referrer"
                  >
                    <MailOutlineRounded />
                  </IconButton>

                  <IconButton
                    href="https://twitter.com/bimsina"
                    target="_blank"
                    referrerPolicy="no-referrer"
                  >
                    <Twitter />
                  </IconButton>

                  <IconButton
                    href="https://www.linkedin.com/in/bimsina/"
                    target="_blank"
                    referrerPolicy="no-referrer"
                  >
                    <LinkedIn />
                  </IconButton>
                </div>
              </Grid>
            </Grid>
          </Grid>
        </Grid>

        <Typography
          style={{
            display: "flex",
            justifyContent: "center",
            marginTop: "1rem",
          }}
        >
          Made by
          <a
            href="https://twitter.com/bimsina"
            target="_blank"
            rel="noopener noreferrer"
            style={{
              margin: "0 0.25rem",
            }}
          >
            Bibek Timsina
          </a>
          and
          <a
            href="https://github.com/bimsina/fluttertemplates.dev/graphs/contributors"
            target="_blank"
            rel="noopener noreferrer"
            style={{ marginLeft: "0.25rem" }}
          >
            contributors
          </a>
        </Typography>
      </AppBar>
    </div>
  );
}
