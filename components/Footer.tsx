import { IconButton, Typography } from "@material-ui/core";
import { MailOutlineRounded, Twitter, GitHub } from "@material-ui/icons";

export default function Footer() {
  return (
    <div
      style={{
        background: "#1b1921",
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
            color: "white",
          }}
        >
          Contact Us
        </Typography>
      </div>

      <div
        style={{
          display: "flex",
          justifyContent: "center",
        }}
      >
        <IconButton
          href="https://twitter.com/bimsina"
          target="_blank"
          referrerPolicy="no-referrer"
        >
          <Twitter className="footer-icon" />
        </IconButton>

        <IconButton href="mailto:fluttertemplatesdev@gmail.com">
          <MailOutlineRounded className="footer-icon" />
        </IconButton>
      </div>
    </div>
  );
}
