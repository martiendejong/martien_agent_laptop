<?php
/**
 * Generate FAQs for blog posts and upload via REST API
 * Run on production server, self-deletes after completion
 * Usage: https://artrevisionist.com/ar-generate-post-faqs.php?key=ar-faq-gen-2026
 */

if (($_GET['key'] ?? '') !== 'ar-faq-gen-2026') {
    http_response_code(403);
    die('Access denied.');
}

header('Content-Type: text/plain; charset=utf-8');

// Load WordPress
define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-load.php';

// OpenAI API key
$openai_key = 'OPENAI_KEY_PLACEHOLDER';

// Get all blog posts (including scheduled)
$posts = get_posts([
    'post_type' => 'post',
    'post_status' => ['publish', 'future'],
    'posts_per_page' => -1,
    'orderby' => 'date',
    'order' => 'ASC'
]);

echo "Found " . count($posts) . " blog posts\n\n";

// Get all pages/posts for cross-linking
$all_content = get_posts([
    'post_type' => ['post', 'page', 'b2bk_topic', 'b2bk_topic_page', 'b2bk_detail'],
    'post_status' => ['publish', 'future'],
    'posts_per_page' => -1
]);

$related_pages = [];
foreach ($all_content as $c) {
    $related_pages[] = [
        'title' => $c->post_title,
        'url' => get_permalink($c),
        'type' => $c->post_type
    ];
}
$related_pages_text = "";
foreach ($related_pages as $rp) {
    $related_pages_text .= "- [{$rp['title']}]({$rp['url']}) ({$rp['type']})\n";
}

// Load prompt template
$prompts_file = '/home/u63291p434771/faq-generation.prompts.json';
if (file_exists($prompts_file)) {
    $prompts = json_decode(file_get_contents($prompts_file), true);
} else {
    // Inline fallback
    $prompts = [
        'system' => 'You are an SEO and FAQ specialist for Art Revisionist, a scholarly platform focused on African art provenance and colonial narratives. Generate 5 high-quality FAQ entries that answer natural search queries, are academically sound, and contextually relevant.',
        'user_template' => "Generate 5 FAQ entries for this page:\n\n## Page Information\n**Title:** {{title}}\n**URL:** {{url}}\n\n## Content:\n{{content}}\n\n## Related Pages (for subtle linking):\n{{related_pages}}\n\nReturn ONLY a JSON object: {\"faqs\":[{\"question\":\"...\",\"answer\":\"...\"},...]} with EXACTLY 5 entries. No markdown, no extra text."
    ];
}

$system_prompt = $prompts['system'];
$user_template = $prompts['user_template'];

$results = [];
foreach ($posts as $post) {
    echo "Processing: [{$post->ID}] {$post->post_title}\n";

    // Check if already has FAQs
    $existing = get_post_meta($post->ID, 'b2bk_qa_items', true);
    if (!empty($existing) && is_array($existing) && count($existing) >= 3) {
        echo "  -> Already has " . count($existing) . " FAQs, skipping\n\n";
        $results[] = ['id' => $post->ID, 'title' => $post->post_title, 'status' => 'skipped', 'count' => count($existing)];
        continue;
    }

    $content = wp_strip_all_tags($post->post_content);
    if (strlen($content) > 4000) {
        $content = substr($content, 0, 4000) . '...';
    }

    $user_msg = str_replace(
        ['{{title}}', '{{url}}', '{{content}}', '{{related_pages}}'],
        [$post->post_title, get_permalink($post), $content, $related_pages_text],
        $user_template
    );

    // Call OpenAI
    $ch = curl_init('https://api.openai.com/v1/chat/completions');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'Authorization: Bearer ' . $openai_key
        ],
        CURLOPT_POSTFIELDS => json_encode([
            'model' => 'gpt-4o',
            'messages' => [
                ['role' => 'system', 'content' => $system_prompt],
                ['role' => 'user', 'content' => $user_msg]
            ],
            'temperature' => 0.7,
            'max_tokens' => 2000
        ]),
        CURLOPT_TIMEOUT => 60
    ]);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($http_code !== 200) {
        echo "  -> OpenAI API error (HTTP $http_code)\n\n";
        $results[] = ['id' => $post->ID, 'title' => $post->post_title, 'status' => 'error', 'error' => "HTTP $http_code"];
        continue;
    }

    $data = json_decode($response, true);
    $content_text = $data['choices'][0]['message']['content'] ?? '';

    // Clean up response (remove markdown code blocks if present)
    $content_text = preg_replace('/^```json\s*/', '', trim($content_text));
    $content_text = preg_replace('/\s*```$/', '', $content_text);

    $faqs_data = json_decode($content_text, true);

    if (!$faqs_data || !isset($faqs_data['faqs']) || !is_array($faqs_data['faqs'])) {
        echo "  -> Failed to parse FAQ JSON\n";
        echo "  -> Raw: " . substr($content_text, 0, 200) . "\n\n";
        $results[] = ['id' => $post->ID, 'title' => $post->post_title, 'status' => 'parse_error'];
        continue;
    }

    // Convert to qa_items format
    $qa_items = [];
    foreach ($faqs_data['faqs'] as $faq) {
        $qa_items[] = [
            'question' => sanitize_text_field($faq['question']),
            'answer' => wp_kses_post($faq['answer'])
        ];
    }

    // Save to post meta
    update_post_meta($post->ID, 'b2bk_qa_items', $qa_items);

    echo "  -> Saved " . count($qa_items) . " FAQs\n\n";
    $results[] = ['id' => $post->ID, 'title' => $post->post_title, 'status' => 'success', 'count' => count($qa_items)];

    // Rate limit
    sleep(2);
}

echo "\n=== SUMMARY ===\n";
foreach ($results as $r) {
    $status = $r['status'];
    $count = $r['count'] ?? 0;
    echo "[{$r['id']}] {$r['title']} -> $status" . ($count ? " ($count FAQs)" : "") . "\n";
}

echo "\nDone! Deleting this script...\n";
@unlink(__FILE__);
echo "Script deleted.\n";
