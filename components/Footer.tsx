import { IconButton, Typography } from "@material-ui/core";
import {
  MailOutlineRounded,
  Twitter,
  GitHub,
  LinkedIn,
} from "@material-ui/icons";

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
          Contact
        </Typography>
      </div>

      <div
        style={{
          display: "flex",
          justifyContent: "center",
        }}
      >
        <a href="mailto:fluttertemplatesdev@gmail.com" aria-label="E-mail">
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
    </div>
  );
}
