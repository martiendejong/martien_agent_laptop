<?php
/**
 * Generate FAQs for ONE blog post at a time
 * Usage: ?key=ar-faq-gen-2026 (auto-picks next post without FAQs)
 * Usage: ?key=ar-faq-gen-2026&post_id=32480 (specific post)
 * Usage: ?key=ar-faq-gen-2026&action=status (check status)
 * Usage: ?key=ar-faq-gen-2026&action=cleanup (delete this script)
 */

if (($_GET['key'] ?? '') !== 'ar-faq-gen-2026') {
    http_response_code(403);
    die('Access denied.');
}

header('Content-Type: application/json; charset=utf-8');
set_time_limit(120);

define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-load.php';

$action = $_GET['action'] ?? 'generate';
$specific_id = isset($_GET['post_id']) ? absint($_GET['post_id']) : 0;

// Status check
if ($action === 'status') {
    $posts = get_posts([
        'post_type' => 'post',
        'post_status' => ['publish', 'future'],
        'posts_per_page' => -1,
        'orderby' => 'date',
        'order' => 'ASC'
    ]);

    $result = [];
    foreach ($posts as $p) {
        $faqs = get_post_meta($p->ID, 'b2bk_qa_items', true);
        $result[] = [
            'id' => $p->ID,
            'title' => $p->post_title,
            'status' => $p->post_status,
            'date' => $p->post_date,
            'faq_count' => is_array($faqs) ? count($faqs) : 0
        ];
    }
    echo json_encode(['posts' => $result, 'total' => count($result)], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}

// Cleanup
if ($action === 'cleanup') {
    @unlink(__FILE__);
    echo json_encode(['deleted' => true]);
    exit;
}

// Generate: find next post without FAQs (or use specific ID)
if ($specific_id) {
    $post = get_post($specific_id);
    if (!$post || $post->post_type !== 'post') {
        echo json_encode(['error' => 'Post not found']);
        exit;
    }
} else {
    $posts = get_posts([
        'post_type' => 'post',
        'post_status' => ['publish', 'future'],
        'posts_per_page' => -1,
        'orderby' => 'date',
        'order' => 'ASC'
    ]);

    $post = null;
    foreach ($posts as $p) {
        $existing = get_post_meta($p->ID, 'b2bk_qa_items', true);
        if (empty($existing) || !is_array($existing) || count($existing) < 3) {
            $post = $p;
            break;
        }
    }

    if (!$post) {
        echo json_encode(['message' => 'All posts already have FAQs', 'done' => true]);
        exit;
    }
}

// Get related content for cross-linking
$all_content = get_posts([
    'post_type' => ['post', 'page', 'b2bk_topic', 'b2bk_topic_page', 'b2bk_detail'],
    'post_status' => ['publish', 'future'],
    'posts_per_page' => 50
]);

$related_pages_text = "";
foreach ($all_content as $c) {
    if ($c->ID === $post->ID) continue;
    $related_pages_text .= "- [{$c->post_title}](" . get_permalink($c) . ") ({$c->post_type})\n";
}

// Prompt
$system = 'You are an SEO and FAQ specialist for Art Revisionist, a scholarly platform focused on African art provenance and colonial narratives. Generate high-quality FAQ entries that answer natural search queries, are academically sound, and contextually relevant to the specific page.';

$content = wp_strip_all_tags($post->post_content);
if (strlen($content) > 4000) $content = substr($content, 0, 4000) . '...';

$user_msg = "Generate 5 FAQ entries for this blog post:

## Post Information
**Title:** {$post->post_title}
**URL:** " . get_permalink($post) . "

## Content:
$content

## Related Pages (for subtle linking):
$related_pages_text

## Requirements:
- 1-2 definition questions (What is.../What does... mean)
- 1-2 process/explanation questions (How does.../How did...)
- 1 context/motivation question (Why.../When...)
- Natural voice-search-friendly questions
- 2-4 sentences per answer (50-120 words)
- Max 1-2 cross-links per answer, only if genuinely relevant
- ONLY use facts from the content above, no external knowledge

Return ONLY a JSON object: {\"faqs\":[{\"question\":\"...\",\"answer\":\"...\"},...]} with EXACTLY 5 entries. No markdown, no extra text.";

// Call OpenAI
$openai_key = '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';

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
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => $user_msg]
        ],
        'temperature' => 0.7,
        'max_tokens' => 2000
    ]),
    CURLOPT_TIMEOUT => 90
]);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($http_code !== 200) {
    echo json_encode(['error' => "OpenAI HTTP $http_code", 'post_id' => $post->ID, 'response' => substr($response, 0, 500)]);
    exit;
}

$data = json_decode($response, true);
$content_text = $data['choices'][0]['message']['content'] ?? '';

// Clean markdown blocks
$content_text = preg_replace('/^```json\s*/', '', trim($content_text));
$content_text = preg_replace('/\s*```$/', '', $content_text);

$faqs_data = json_decode($content_text, true);

if (!$faqs_data || !isset($faqs_data['faqs']) || !is_array($faqs_data['faqs'])) {
    echo json_encode(['error' => 'Failed to parse FAQ JSON', 'post_id' => $post->ID, 'raw' => substr($content_text, 0, 500)]);
    exit;
}

// Save
$qa_items = [];
foreach ($faqs_data['faqs'] as $faq) {
    $qa_items[] = [
        'question' => sanitize_text_field($faq['question']),
        'answer' => wp_kses_post($faq['answer'])
    ];
}

update_post_meta($post->ID, 'b2bk_qa_items', $qa_items);

echo json_encode([
    'success' => true,
    'post_id' => $post->ID,
    'title' => $post->post_title,
    'faq_count' => count($qa_items),
    'faqs' => $qa_items
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
