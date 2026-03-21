# UI Components Quick Reference - IMAGE-FIRST

**CRITICAL:** Every component below REQUIRES images. No exceptions.

---

## 1. Hero with Background Image (MANDATORY)

```html
<section class="hero">
    <div class="container">
        <h1>[Headline]</h1>
        <p class="tagline">[Value proposition]</p>
        <a href="tel:[PHONE]" class="btn">Bel: [PHONE]</a>
    </div>
</section>

<style>
.hero {
    background: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)),
                url('[IMAGE-URL]');
    background-size: cover;
    background-position: center;
    color: white;
    padding: 6rem 0;
    text-align: center;
    min-height: 500px;
}
</style>
```

---

## 2. Team Member with Photo (MANDATORY if team section)

```html
<div class="team-member">
    <img src="[PHOTO]" alt="[Name]" class="team-photo">
    <h3>[Name] ([Age])</h3>
    <div class="role">[Role]</div>
    <div class="quote">"[Quote]"</div>
</div>

<style>
.team-photo {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    object-fit: cover;
    border: 4px solid var(--accent);
}
</style>
```

---

## 3. Product Card with Image (MANDATORY if products)

```html
<div class="product-card">
    <img src="[PRODUCT-IMAGE]" alt="[Product]" class="product-image">
    <h3>[Product Name]</h3>
    <p>[Description]</p>
    <div class="price">€XX</div>
</div>

<style>
.product-image {
    width: 100%;
    height: 250px;
    object-fit: cover;
    border-radius: 8px 8px 0 0;
}
</style>
```

---

## 4. Location with Photo + Map (MANDATORY if physical location)

```html
<div class="location-grid">
    <div class="location-photo">
        <img src="[STOREFRONT]" alt="Locatie">
    </div>
    <div class="location-info">
        <p><strong>📍 Adres:</strong><br>[Address]</p>
        <iframe src="https://www.google.com/maps/embed?pb=[CODE]"
                width="100%" height="300" loading="lazy"></iframe>
    </div>
</div>
```

---

## 5. Process Step with Photo (RECOMMENDED)

```html
<div class="step">
    <div class="step-number">1</div>
    <img src="[PROCESS-PHOTO]" alt="Step 1" class="step-image">
    <h3>[Step Name]</h3>
    <p>[What happens]</p>
</div>

<style>
.step-image {
    width: 100%;
    height: 200px;
    object-fit: cover;
    border-radius: 8px;
}
</style>
```

---

## Quick Image URLs (Unsplash)

```
Hero: https://source.unsplash.com/1600x900/?[keyword]
Team: https://source.unsplash.com/400x400/?portrait,professional
Product: https://source.unsplash.com/800x600/?[product-keyword]
Location: https://source.unsplash.com/1200x800/?storefront,[city]
Process: https://source.unsplash.com/800x600/?workspace,[keyword]
```

**Keywords:**
- Coffee: `coffee,roasting,beans`
- Bakery: `bakery,bread,artisan`
- Gym: `gym,fitness,equipment`
- Restaurant: `restaurant,dining,food`
- Office: `office,workspace,professional`

---

## Color Schemes (Copy-Paste)

```css
/* Coffee/Bakery */
--primary: #6B4423;
--secondary: #D4A373;
--accent: #8B4513;

/* Professional/Tech */
--primary: #2563EB;
--secondary: #1E40AF;
--accent: #E3F2FD;

/* Health/Garden */
--primary: #4CAF50;
--secondary: #388E3C;
--accent: #E8F5E9;

/* Gym/Active */
--primary: #FF5722;
--secondary: #2F2F2F;
--accent: #FFEBEE;
```

---

## Typography (Google Fonts)

```html
<!-- Elegant -->
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@400;700&display=swap">

<!-- Modern -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap">

<!-- Bold -->
<link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;700&family=Roboto:wght@400;700&display=swap">
```

---

## Starter Template (Complete)

```html
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Business] - [Tagline]</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2563EB;
            --secondary: #1E40AF;
            --accent: #E3F2FD;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Poppins', sans-serif;
            color: #333;
            line-height: 1.6;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 1.5rem;
        }
        .hero {
            background: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)),
                        url('[HERO-IMAGE]');
            background-size: cover;
            background-position: center;
            color: white;
            padding: 6rem 0;
            text-align: center;
        }
    </style>
</head>
<body>
    <section class="hero">
        <div class="container">
            <h1>[Headline]</h1>
            <p>[Tagline]</p>
        </div>
    </section>
</body>
</html>
```

---

**Last Updated:** 2026-02-27
**Source:** V8 image-first patterns
