// Article Seeder Script for Semesta Lestari
const db = require("../config/database");
const { pool } = require('../config/database');

const articles = [
  {
    title: "Konservasi Hutan Indonesia",
    subtitle: "Upaya pelestarian hutan dan keanekaragaman hayati",
    content:
      "Indonesia memiliki hutan tropis yang sangat luas dan beragam. Upaya konservasi dilakukan melalui reboisasi, perlindungan satwa, dan edukasi masyarakat.",
    image_url: "https://picsum.photos/seed/konservasi/800/400",
    author_id: 1,
    category_id: 1,
    published_at: new Date(),
    is_active: true,
    view_count: 0,
  },
  {
    title: "Energi Terbarukan untuk Masa Depan",
    subtitle: "Solusi energi ramah lingkungan",
    content:
      "Pengembangan energi terbarukan seperti solar dan angin menjadi fokus utama untuk mengurangi emisi karbon dan menjaga lingkungan.",
    image_url: "https://picsum.photos/seed/energi/800/400",
    author_id: 2,
    category_id: 2,
    published_at: new Date(),
    is_active: true,
    view_count: 0,
  },
  {
    title: "Edukasi Lingkungan di Sekolah",
    subtitle: "Membangun generasi peduli lingkungan",
    content:
      "Program edukasi lingkungan di sekolah bertujuan meningkatkan kesadaran generasi muda tentang pentingnya menjaga alam.",
    image_url: "https://picsum.photos/seed/edukasi/800/400",
    author_id: 3,
    category_id: 3,
    published_at: new Date(),
    is_active: true,
    view_count: 0,
  },
];

async function seed() {
  for (const article of articles) {
      await pool.query(
      "INSERT INTO articles (title, subtitle, content, image_url, author_id, category_id, published_at, is_active, view_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        article.title,
        article.subtitle,
        article.content,
        article.image_url,
        article.author_id,
        article.category_id,
        article.published_at,
        article.is_active,
        article.view_count,
      ],
    );
  }
  console.log("Seeded articles successfully!");
  process.exit(0);
}

seed().catch((err) => {
  console.error("Seeder error:", err);
  process.exit(1);
});
