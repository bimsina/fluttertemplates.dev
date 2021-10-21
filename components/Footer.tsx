import { AppBar, Typography } from "@material-ui/core";
import { LinkedIn, MailOutlineRounded, Twitter } from "@material-ui/icons";

export default function Footer() {
  return (
    <AppBar
      position="static"
      color="primary"
      style={{
        padding: "2.5rem",
        width: "100%",
      }}
    >
      {/* <Grid
        container
        justifyContent="center"
        alignItems="center"
        style={{
          width: "100%",
          display: "flex",
          justifyContent: "center",
          marginBottom: "2rem",
        }}
      >
        <Grid item>
          <Typography
            style={{
              fontSize: "1rem",
              fontWeight: "bold",
              marginLeft: "4px",
              color: "white",
            }}
          >
            Find an issue with the page?
          </Typography>
        </Grid>

        <Grid>
          <a
            aria-label="File an issue"
            href="https://github.com/bimsina/fluttertemplates.dev/issues"
            target="_blank"
            rel="noopener noreferrer"
          >
            <CustomButton
              style={{
                color: "#c4d33a",
                paddingLeft: "8px",
              }}
            >
              Post it on GitHub!
            </CustomButton>
          </a>
        </Grid>
      </Grid> */}
      <div
        style={{
          width: "100%",
          display: "flex",
          justifyContent: "center",
        }}
      >
        <Typography
          style={{
            textTransform: "capitalize",
            fontSize: "1rem",
            fontWeight: "bold",
            marginLeft: "4px",
            color: "white",
          }}
        >
          Contact
        </Typography>
      </div>
      <div
        style={{
          display: "flex",
          justifyContent: "center",
        }}
      >
        <a href="mailto:timsinabibek960@gmail.com" aria-label="E-mail">
          <MailOutlineRounded className="footer-icon" />
        </a>
        <a
          aria-label="Twitter"
          href="https://twitter.com/bimsina"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Twitter className="footer-icon" />
        </a>

        <a
          aria-label="LinkedIn"
          href="https://www.linkedin.com/in/bimsina/"
          target="_blank"
          rel="noopener noreferrer"
        >
          <LinkedIn className="footer-icon" />
        </a>
      </div>

      <div
        style={{
          display: "flex",
          justifyContent: "center",
        }}
      >
        © 2021 Bibek Timsina
      </div>
    </AppBar>
  );
}
