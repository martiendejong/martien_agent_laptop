<?php
/**
 * Fetch all content from ArtRevisionist for analysis
 * Usage: ?key=ar-faq-gen-2026
 */
if (($_GET['key'] ?? '') !== 'ar-faq-gen-2026') { http_response_code(403); die('Access denied.'); }

header('Content-Type: application/json; charset=utf-8');
define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-load.php';

$all = [];

// Blog posts
$posts = get_posts(['post_type'=>'post','post_status'=>['publish','future'],'posts_per_page'=>-1,'orderby'=>'date','order'=>'ASC']);
foreach ($posts as $p) {
    $content = wp_strip_all_tags($p->post_content);
    $all['posts'][] = [
        'id'=>$p->ID, 'title'=>$p->post_title, 'status'=>$p->post_status,
        'date'=>$p->post_date, 'slug'=>$p->post_name,
        'excerpt'=>substr($content, 0, 500),
        'word_count'=>str_word_count($content),
        'faqs'=>get_post_meta($p->ID,'b2bk_qa_items',true)?:[]
    ];
}

// Topics
$topics = get_posts(['post_type'=>'b2bk_topic','post_status'=>'any','posts_per_page'=>-1]);
foreach ($topics as $t) {
    $all['topics'][] = ['id'=>$t->ID,'title'=>$t->post_title,'slug'=>$t->post_name,'status'=>$t->post_status];
}

// Topic pages
$tpages = get_posts(['post_type'=>'b2bk_topic_page','post_status'=>'any','posts_per_page'=>-1]);
foreach ($tpages as $tp) {
    $parent = get_post_meta($tp->ID,'b2bk_parent_topic_id',true);
    $all['topic_pages'][] = ['id'=>$tp->ID,'title'=>$tp->post_title,'slug'=>$tp->post_name,'parent_topic'=>$parent,'status'=>$tp->post_status];
}

// Pages
$pages = get_posts(['post_type'=>'page','post_status'=>['publish','future'],'posts_per_page'=>-1]);
foreach ($pages as $pg) {
    $all['pages'][] = ['id'=>$pg->ID,'title'=>$pg->post_title,'slug'=>$pg->post_name];
}

echo json_encode($all, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
