class_name LevelResource extends Resource

var right_connection := ConnectionState.Closed
var bottom_connection := ConnectionState.Closed

var top_connection := ConnectionState.Closed
var left_connection := ConnectionState.Closed


enum ConnectionState {
	Open,
	Closed,
	EdgeOfMap
}
