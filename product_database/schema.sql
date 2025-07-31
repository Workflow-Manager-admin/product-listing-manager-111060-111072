-- Product Listing Manager Database Schema
-- Supports products, channels, listings, images, statuses, and user sessions
-- For extensible multi-channel e-commerce listing synchronization
-- PUBLIC_INTERFACE: This schema is designed to be migrated/managed with standard PostgreSQL tools.

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- E-commerce sales channels (e.g., Lazada, Shopee, TikTok, etc.)
CREATE TABLE IF NOT EXISTS channels (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    api_type VARCHAR(50), -- e.g., 'lazada', 'shopee', 'tiktok'
    description TEXT,
    country_code VARCHAR(8),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Product details (shared fields; per-listing fields live in listings)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(80) UNIQUE,
    category VARCHAR(128),
    brand VARCHAR(128),
    price NUMERIC(18,2),
    stock INTEGER,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Product images
CREATE TABLE IF NOT EXISTS images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    alt_text VARCHAR(512),
    uploaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    -- image metadata suitable for pre-fill/image analysis
    metadata JSONB
);

-- Product listing (records a product's publication on one channel/country)
CREATE TABLE IF NOT EXISTS listings (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    channel_id INTEGER REFERENCES channels(id) ON DELETE CASCADE,
    channel_listing_id VARCHAR(255), -- ID on e-commerce platform
    country_code VARCHAR(8),
    status VARCHAR(32) DEFAULT 'pending', -- e.g. pending/success/failed/syncing
    status_message TEXT,
    synced_at TIMESTAMPTZ,
    last_synced_by INTEGER REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    -- Extensible: channel-specific fields
    channel_payload JSONB
);

-- Listing status history and audit (tracking update status, errors)
CREATE TABLE IF NOT EXISTS listing_sync_status (
    id SERIAL PRIMARY KEY,
    listing_id INTEGER REFERENCES listings(id) ON DELETE CASCADE,
    status VARCHAR(32) NOT NULL,
    message TEXT,
    occurred_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    performed_by INTEGER REFERENCES users(id)
);

-- User sessions (for session and auth management)
CREATE TABLE IF NOT EXISTS user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL,
    user_agent TEXT,
    ip TEXT
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_sku ON products (sku);
CREATE INDEX IF NOT EXISTS idx_listings_channel_product ON listings (channel_id, product_id);
CREATE INDEX IF NOT EXISTS idx_images_product_id ON images (product_id);
CREATE INDEX IF NOT EXISTS idx_listing_sync_listing_id ON listing_sync_status (listing_id);
