import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api.dart';

class AppReceitas extends StatefulWidget {
  @override
  _AppReceitasState createState() => _AppReceitasState();
}

class _AppReceitasState extends State<AppReceitas> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReceitaHomePage(),
    );
  }
}

class ReceitaHomePage extends StatefulWidget {
  @override
  _ReceitaHomePageState createState() => _ReceitaHomePageState();
}

class _ReceitaHomePageState extends State<ReceitaHomePage> {
  List recipes = [];
  String? selectedCuisine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedCuisine == null) {
        _showCuisineSelectionDialog();
      }
    });
  }

  Future<void> fetchRecipes() async {
    if (selectedCuisine == null) return;
    List fetchedRecipes = await ApiService.fetchRecipes(selectedCuisine!);
    setState(() {
      recipes = fetchedRecipes;
    });
  }

  void _showCuisineSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolha uma culinária'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'American', 'Chinese', 'French', 'Greek', 'Indian', 'Italian',
              'Japanese', 'Mexican', 'Portuguese', 'Spanish'
            ].map((String choice) {
              return ListTile(
                title: Text(choice),
                onTap: () async {
                  setState(() {
                    selectedCuisine = choice;
                  });

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(child: CircularProgressIndicator());
                    },
                  );

                  await fetchRecipes();

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receitas de ${selectedCuisine ?? "Escolha uma culinária"}'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: _showCuisineSelectionDialog,
          ),
        ],
      ),
      body: recipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            leading: Image.network(recipe['strMealThumb'], width: 50, height: 50),
            title: Text(recipe['strMeal']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipeId: recipe['idMeal']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  RecipeDetailPage({required this.recipeId});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map recipe = {};

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    Map fetchedRecipe = await ApiService.fetchRecipeDetails(widget.recipeId);
    setState(() {
      recipe = fetchedRecipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['strMeal'] ?? 'Detalhes da Receita'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: recipe.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              recipe['strMealThumb'] ?? '',
              width: isLandscape ? MediaQuery.of(context).size.width / 2 : double.infinity,
              height: isLandscape ? 200 : null,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text('Ingredientes:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...List.generate(20, (index) {
              String ingredient = recipe['strIngredient${index + 1}'] ?? '';
              String measure = recipe['strMeasure${index + 1}'] ?? '';
              return ingredient.isNotEmpty
                  ? Text('- $ingredient: $measure')
                  : SizedBox.shrink();
            }),
            SizedBox(height: 10),
            Text('Modo de Preparo:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(recipe['strInstructions'] ?? ''),
            SizedBox(height: 10),
            if (recipe['strYoutube'] != null && recipe['strYoutube'].isNotEmpty)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final url = recipe['strYoutube'];
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
                child: Text('Ver Vídeo no YouTube'),
              ),
          ],
        ),
      ),
    );
  }
}
