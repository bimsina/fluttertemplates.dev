import { AppBar, Divider, IconButton, Typography } from "@material-ui/core";
import { LinkedIn, MailOutlineRounded, Twitter } from "@material-ui/icons";

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

        <div
          style={{
            display: "flex",
            justifyContent: "center",
          }}
        >
          © 2021 Bibek Timsina
        </div>
      </AppBar>
    </div>
  );
}
