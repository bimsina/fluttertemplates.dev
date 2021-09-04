import Link from "next/link";
import {
  AppBar,
  Button,
  IconButton,
  Toolbar,
  Typography,
  Grid,
  Container,
} from "@material-ui/core";

interface HeaderProps {
  icon: any;
  onChange: VoidFunction;
}
export default function Header(props: HeaderProps) {
  return (
    <div
      style={{
        background: "#1b1921",
      }}
    >
      <AppBar position="static" color="transparent" elevation={0}>
        <Container maxWidth="lg">
          <Toolbar>
            <div
              style={{
                flexGrow: 1,
              }}
            >
              <Button
                href="/"
                style={{
                  marginTop: "8px",
                }}
              >
                <Grid container alignItems="center">
                  <Grid item>
                    <img
                      src="/favicon.svg"
                      alt="Flutter UI Templates Logo"
                      style={{
                        height: "2.5rem",
                        width: "auto",
                      }}
                    />
                  </Grid>
                  <Grid item>
                    <Typography
                      color="inherit"
                      style={{
                        textTransform: "capitalize",
                        fontSize: "1.3rem",
                        fontWeight: "bold",
                        marginLeft: "4px",
                        color: "white",
                      }}
                    >
                      Templates
                    </Typography>
                  </Grid>
                </Grid>
              </Button>
            </div>

            <IconButton
              onClick={props.onChange}
              style={{
                color: "white",
              }}
            >
              {props.icon}
            </IconButton>
          </Toolbar>
        </Container>
      </AppBar>
    </div>
  );
}
