import '../models/ingredient.dart';

class AggregateIngredients {
  Map<String, String> execute(List<Ingredient> shoppingList) {
    final Map<String, List<String>> rawGroups = {};
    
    for (var item in shoppingList) {
      if (!rawGroups.containsKey(item.name)) {
        rawGroups[item.name] = [];
      }
      rawGroups[item.name]!.add(item.amount);
    }

    final Map<String, String> aggregated = {};
    
    rawGroups.forEach((name, amounts) {
      double totalNumeric = 0.0;
      List<String> textStrings = [];
      String detectedUnit = "";

      for (var amt in amounts) {
        final RegExp numReg = RegExp(r'([0-9.]+)');
        final RegExp unitReg = RegExp(r'([^0-9.]+)');
        
        var numMatch = numReg.firstMatch(amt);
        var unitMatch = unitReg.firstMatch(amt);

        if (numMatch != null) {
          totalNumeric += double.tryParse(numMatch.group(1)!) ?? 0.0;
          if (unitMatch != null) {
            detectedUnit = unitMatch.group(1)!;
          }
        } else {
          textStrings.add(amt);
        }
      }

      if (totalNumeric > 0.0) {
        String finalNum = totalNumeric % 1 == 0 
            ? totalNumeric.toInt().toString() 
            : totalNumeric.toStringAsFixed(1);
        aggregated[name] = '$finalNum$detectedUnit';
        if (textStrings.isNotEmpty) {
          aggregated[name] = '${aggregated[name]} + ${textStrings.join(", ")}';
        }
      } else {
        aggregated[name] = textStrings.join(", ");
      }
    });

    return aggregated;
  }
}