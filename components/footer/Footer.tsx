import {
  AppBar,
  Divider,
  Grid,
  IconButton,
  Typography,
} from "@material-ui/core";
import { LinkedIn, MailOutlineRounded, Twitter } from "@material-ui/icons";
import { BUY_ME_A_COFFEE_LINK } from "../../constants";
import Link from "next/link";

export default function Footer() {
  return (
    <div>
      <Divider />
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
                    height={40}
                    width={142.47}
                    style={{
                      marginTop: "1rem",
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
      </AppBar>
    </div>
  );
}
