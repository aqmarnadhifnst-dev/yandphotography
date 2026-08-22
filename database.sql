-- ============================================
-- DATABASE: ETERNAL MOMENTS WEDDING PHOTOGRAPHY
-- ============================================

-- 1. TABEL PACKAGES (Paket Pernikahan)
CREATE TABLE packages (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    price BIGINT NOT NULL,
    description TEXT,
    features JSONB NOT NULL DEFAULT '[]',
    is_popular BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. TABEL CLIENTS (Data Klien)
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE,
    phone VARCHAR(20),
    partner_name VARCHAR(200),
    wedding_date DATE,
    venue VARCHAR(300),
    package_id INTEGER REFERENCES packages(id),
    status VARCHAR(50) DEFAULT 'inquiry',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. TABEL GALLERIES (Album Foto)
CREATE TABLE galleries (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id),
    title VARCHAR(200) NOT NULL,
    couple_names VARCHAR(200),
    wedding_date DATE,
    location VARCHAR(200),
    cover_image TEXT,
    description TEXT,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. TABEL PHOTOS (Foto Individual)
CREATE TABLE photos (
    id SERIAL PRIMARY KEY,
    gallery_id INTEGER REFERENCES galleries(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    alt_text VARCHAR(200),
    category VARCHAR(50) DEFAULT 'ceremony',
    is_featured BOOLEAN DEFAULT FALSE,
    order_num INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. TABEL TESTIMONIALS
CREATE TABLE testimonials (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id),
    couple_names VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5) DEFAULT 5,
    wedding_location VARCHAR(200),
    wedding_year INTEGER,
    is_featured BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 6. TABEL INQUIRIES (Dari Form Kontak)
CREATE TABLE inquiries (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(200) NOT NULL,
    email VARCHAR(200),
    whatsapp VARCHAR(20),
    wedding_date DATE,
    package_interest VARCHAR(100),
    message TEXT,
    status VARCHAR(50) DEFAULT 'new',
    created_at TIMESTAMP DEFAULT NOW()
);

-- 7. TABEL BOOKINGS (Kalender Ketersediaan)
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id),
    booking_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(booking_date)
);

-- ============================================
-- DATA AWAL (SEED DATA)
-- ============================================

-- Insert paket default
INSERT INTO packages (name, slug, price, description, features, is_popular) VALUES
('Silver Collection', 'silver', 12000000, 'Sempurna untuk intimate wedding', 
 '["1 Fotografer", "8 Jam Dokumentasi", "300+ Foto Editan", "Online Gallery"]'::jsonb, false),
('Gold Collection', 'gold', 22000000, 'Pilihan terbaik untuk wedding standar', 
 '["2 Fotografer + 1 Videografer", "12 Jam Full Day", "500+ Foto + Cinematic Video", "Pre-wedding 1 Lokasi", "Premium Leather Album"]'::jsonb, true),
('Platinum Collection', 'platinum', 35000000, 'Mewah dan tanpa kompromi', 
 '["3 Fotografer + 2 Videografer + Drone", "Unlimited Hours", "All Photos + Same Day Edit", "Pre & Post-Wedding", "Exclusive Album & Canvas"]'::jsonb, false);

-- Insert testimoni contoh
INSERT INTO testimonials (couple_names, content, rating, wedding_location, wedding_year, is_featured) VALUES
('Sarah & Dimas', 'Andi benar-benar menangkap esensi hari pernikahan kami. Setiap foto bercerita dan membuat kami menangis bahagia.', 5, 'Bali', 2024, true),
('Maya & Rendi', 'Profesional, kreatif, dan sangat mudah diajak kerja sama. Hasilnya melebihi ekspektasi kami!', 5, 'Yogyakarta', 2024, true),
('Lisa & Bryan', 'Investasi terbaik untuk pernikahan kami. Foto-fotonya penuh emosi.', 5, 'Lombok', 2023, true);

-- ============================================
-- INDEXES (Untuk performa)
-- ============================================
CREATE INDEX idx_photos_gallery ON photos(gallery_id);
CREATE INDEX idx_galleries_published ON galleries(is_published);
CREATE INDEX idx_testimonials_featured ON testimonials(is_featured);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_inquiries_status ON inquiries(status);

-- ============================================
-- ROW LEVEL SECURITY (Penting untuk Supabase!)
-- ============================================
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE galleries ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

-- Public bisa baca data yang published
CREATE POLICY "Public can view published galleries" 
ON galleries FOR SELECT USING (is_published = true);

CREATE POLICY "Public can view photos from published galleries" 
ON photos FOR SELECT USING (
    gallery_id IN (SELECT id FROM galleries WHERE is_published = true)
);

CREATE POLICY "Public can view featured testimonials" 
ON testimonials FOR SELECT USING (is_published = true);

CREATE POLICY "Public can view active packages" 
ON packages FOR SELECT USING (is_active = true);

-- Public bisa insert inquiry (dari form kontak)
ALTER TABLE inquiries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can submit inquiry" 
ON inquiries FOR INSERT WITH CHECK (true);
