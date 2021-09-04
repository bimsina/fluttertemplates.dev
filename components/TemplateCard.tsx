import {
  Card,
  CardActionArea,
  CardContent,
  CardMedia,
  Grid,
  Typography,
} from "@material-ui/core";
import Link from "next/link";
import React from "react";
import TemplateCardProps from "../models/template_card";

export default function TemplateCard(props: TemplateCardProps) {
  return (
    <Grid item md={3} xs={12} sm={6}>
      <Link href={`/templates/${props.id}`} passHref>
        <a>
          <Card
            elevation={0}
            style={{
              margin: "16px",
            }}
          >
            <CardActionArea>
              <CardMedia
                image={props.frontmatter.image}
                title={props.frontmatter.title.toString()}
                style={{
                  height: "10rem",
                }}
              />
              <CardContent>
                <Typography
                  gutterBottom
                  variant="h6"
                  style={{
                    fontSize: "1rem",
                  }}
                >
                  {props.frontmatter.title}
                </Typography>
              </CardContent>
            </CardActionArea>
          </Card>
        </a>
      </Link>
    </Grid>
  );
}
