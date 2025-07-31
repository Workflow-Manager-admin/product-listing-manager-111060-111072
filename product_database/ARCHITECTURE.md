# Product Listing Manager Database Schema

## Overview

This schema supports an extensible multi-channel product listing management platform.
It is designed for managing product data, multi-channel e-commerce synchronization (Lazada, Shopee, TikTok, etc.), image metadata, listing statuses, and user sessions.

## Main Tables

- **users**: Registered application users, product creators, and session owners.
- **channels**: Supported e-commerce channels, country mapping, and third-party API metadata.
- **products**: Master product records (title, description, SKU, price, brand, etc.).
- **images**: Images attached to products; includes support for image metadata/analysis (stored as JSONB).
- **listings**: Channel-specific publication records for a product (cross-channel, multi-country).
- **listing_sync_status**: Tracks status/history of sync operations per listing, including errors/audit trail.
- **user_sessions**: For auth/session management in the app.

## Relationships

- Products → Images: One-to-many
- Products → Listings: One-to-many
- Listings → Channels: Many-to-one
- Listings → listing_sync_status: One-to-many (history/audit)
- Listing/user history → Users

## Extensibility

- The `channels` table allows new platforms to be added.
- `listings.channel_payload` supports arbitrary platform-specific info (API responses, mappings, etc.).
- Image metadata enables automatic pre-filling during upload via analysis.
- Status/history tables make system auditable and enable resync/retry logic.

## Example Use-Cases Enabled

- Upload Excel or manual form → Products and Images records created
- Assign country/channel → `listings` rows created per product/channel/country
- Image upload triggers analysis (save to `images.metadata`)
- Sync status from API updates `listings.status` + `listing_sync_status`
- User session tracking for authentication

## Setup

1. Run `startup.sh` in the `product_database` directory to provision the DB.
2. Run `init_db.sh` to apply tables and relationships.

> Environment variables for DB connection (see `db_visualizer/postgres.env`):
> - POSTGRES_URL
> - POSTGRES_USER
> - POSTGRES_PASSWORD
> - POSTGRES_DB
> - POSTGRES_PORT

## ER Diagram

```
users            channels
  |                 |
  |                 |
products ---< listings >--- channels
  |             |
images          listing_sync_status
        |
user_sessions
```

- Arrow (---<) indicates one-to-many relationships.
