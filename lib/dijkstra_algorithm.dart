class Graph {
  final Map<String, Map<String, double>> _graph;

  Graph(this._graph);

  List<String> shortestPath(String start, String end) {
    final Map<String, double> distances = {};
    final Map<String, String> previous = {};
    final Set<String> visited = {};

    // Initialize distances
    for (var node in _graph.keys) {
      distances[node] = double.infinity;
    }
    distances[start] = 0;

    while (visited.length < _graph.length) {
      final String currentNode = _minDistanceNode(distances, visited);
      visited.add(currentNode);
      if (currentNode == end) {
        break;
      }
      if (_graph[currentNode] == null) {
        continue;
      }
      for (final neighbor in _graph[currentNode]!.keys) {
        final double distance = _graph[currentNode]![neighbor]!;
        final double newDistance = distances[currentNode]! + distance;
        if (newDistance < distances[neighbor]!) {
          distances[neighbor] = newDistance;
          previous[neighbor] = currentNode;
        }
      }
    }

    // Build the shortest path
    List<String> path = [];
    String? node = end;
    while (node != null) {
      path.add(node);
      node = previous[node];
    }
    path = path.reversed.toList();
    return path;
  }

  String _minDistanceNode(Map<String, double> distances, Set<String> visited) {
    double minDistance = double.infinity;
    String minNode = '';
    for (final node in _graph.keys) {
      if (distances[node]! < minDistance && !visited.contains(node)) {
        minDistance = distances[node]!;
        minNode = node;
      }
    }
    return minNode;
  }
}
