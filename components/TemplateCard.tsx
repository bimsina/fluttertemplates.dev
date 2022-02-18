import TemplateCardProps from "@/models/template_card";
import { Card, CardMedia, Grid, Typography } from "@mui/material";
import Link from "next/link";
import React from "react";

export default function TemplateCard(props: TemplateCardProps) {
  return (
    <Grid item md={3} xs={12} sm={6}>
      <Link href={`/templates/${props.id}`} passHref>
        <a>
          <Card elevation={0}>
            <CardMedia
              image={props.frontmatter.image}
              title={props.frontmatter.title.toString()}
              style={{
                height: "9rem",
              }}
            />

            <Typography
              gutterBottom
              variant="h6"
              style={{
                fontSize: "1rem",
                margin: "10px",
              }}
            >
              {props.frontmatter.title}
            </Typography>

            {/* <div
                className="categories-list"
                style={{
                  marginLeft: "8px",
                }}
              >
                {props.frontmatter.categories.map((category) => (
                  <Chip
                    label={category}
                    style={{
                      marginRight: "4px",
                    }}
                  />
                ))}
              </div> */}
          </Card>
        </a>
      </Link>
    </Grid>
  );
}
