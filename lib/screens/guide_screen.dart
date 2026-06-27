import 'package:flutter/material.dart';
import '../data/guide_data.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  GuideCategory? _selectedCategory;
  GuideArticle?  _selectedArticle;

  // ── Colors ──────────────────────────────────────────────────────────────────
  static const _bg        = Color(0xFF100E08);
  static const _parchment = Color(0xFF1A1610);
  static const _copper    = Color(0xFFB87333);
  static const _text      = Color(0xFFD4C5A9);
  static const _dimText   = Color(0xFF7A6E58);
  static const _border    = Color(0xFF3A3020);
  static const _divider   = Color(0xFF2A2418);

  void _openCategory(GuideCategory cat) {
    setState(() {
      _selectedCategory = cat;
      _selectedArticle  = null;
    });
  }

  void _openArticle(GuideArticle art) {
    setState(() => _selectedArticle = art);
  }

  void _back() {
    setState(() {
      if (_selectedArticle != null) {
        _selectedArticle = null;
      } else {
        _selectedCategory = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _parchment,
        foregroundColor: _copper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: _selectedCategory == null
              ? () => Navigator.pop(context)
              : _back,
        ),
        title: Text(
          _selectedArticle != null
              ? _selectedArticle!.title
              : _selectedCategory != null
                  ? _selectedCategory!.title
                  : 'Guide',
          style: const TextStyle(
            color: _copper,
            fontSize: 15,
            letterSpacing: 1.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _selectedArticle != null
            ? _ArticleView(article: _selectedArticle!, key: ValueKey(_selectedArticle!.title))
            : _selectedCategory != null
                ? _ArticleList(
                    category: _selectedCategory!,
                    onSelect: _openArticle,
                    key: ValueKey(_selectedCategory!.id),
                  )
                : _CategoryList(onSelect: _openCategory, key: const ValueKey('cats')),
      ),
    );
  }
}

// ── Category grid ─────────────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  final void Function(GuideCategory) onSelect;
  const _CategoryList({required this.onSelect, super.key});

  static const _copper  = Color(0xFFB87333);
  static const _text    = Color(0xFFD4C5A9);
  static const _dimText = Color(0xFF7A6E58);
  static const _border  = Color(0xFF3A3020);
  static const _card    = Color(0xFF1A1610);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 4),
        Text(
          'SELECT A TOPIC',
          style: TextStyle(color: _dimText, fontSize: 10, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        for (final cat in allGuideCategories) ...[
          _CategoryTile(category: cat, onTap: () => onSelect(cat)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final GuideCategory category;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.onTap});

  static const _copper = Color(0xFFB87333);
  static const _text   = Color(0xFFD4C5A9);
  static const _dim    = Color(0xFF7A6E58);
  static const _border = Color(0xFF3A3020);
  static const _card   = Color(0xFF1A1610);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Text(category.icon, style: TextStyle(color: _copper, fontSize: 18)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${category.articles.length} article${category.articles.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: _dim, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _dim, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Article list ──────────────────────────────────────────────────────────────

class _ArticleList extends StatelessWidget {
  final GuideCategory category;
  final void Function(GuideArticle) onSelect;
  const _ArticleList({required this.category, required this.onSelect, super.key});

  static const _dimText = Color(0xFF7A6E58);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 4),
        Text(
          '${category.articles.length} ARTICLES',
          style: const TextStyle(color: _dimText, fontSize: 10, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        for (final art in category.articles) ...[
          _ArticleTile(article: art, onTap: () => onSelect(art)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final GuideArticle article;
  final VoidCallback onTap;
  const _ArticleTile({required this.article, required this.onTap});

  static const _text   = Color(0xFFD4C5A9);
  static const _dim    = Color(0xFF7A6E58);
  static const _border = Color(0xFF3A3020);
  static const _card   = Color(0xFF1A1610);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _card,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  article.title,
                  style: const TextStyle(color: _text, fontSize: 14),
                ),
              ),
              const Icon(Icons.chevron_right, color: _dim, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Article view ──────────────────────────────────────────────────────────────

class _ArticleView extends StatelessWidget {
  final GuideArticle article;
  const _ArticleView({required this.article, super.key});

  static const _copper  = Color(0xFFB87333);
  static const _text    = Color(0xFFD4C5A9);
  static const _dimText = Color(0xFF7A6E58);
  static const _divider = Color(0xFF2A2418);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        for (final block in article.blocks) ...[
          if (block.isHeader) ...[
            const SizedBox(height: 16),
            Text(
              block.text.toUpperCase(),
              style: const TextStyle(
                color: _copper,
                fontSize: 10,
                letterSpacing: 1.6,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Container(height: 1, color: _divider),
            const SizedBox(height: 8),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                block.text,
                style: const TextStyle(
                  color: _text,
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
