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
        <a
          aria-label="Twitter"
          href="https://twitter.com/bimsina"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Twitter className="footer-icon" />
        </a>

        <a href="mailto:fluttertemplatesdev@gmail.com" aria-label="E-mail">
          <MailOutlineRounded className="footer-icon" />
        </a>
      </div>
    </div>
  );
}
