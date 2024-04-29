from math import sqrt
import random


class Point:
    def __init__(self,x,y,z):
        self.x = x
        self.y = y
        self.z = z

def manhatan_distance(point1:list, point2:list):
    return round(abs(point1[0] - point2[0]) + abs(point1[1] - point2[1]) + abs(point1[2]-point2[2]),2)

def euclidean_distance(point1:list, point2:list):
    return round(sqrt(((point1[0]-point2[0])**2) +((point1[1] - point2[1]) **2) + ((point1[2] - point2[2]) **2)), 2)

def read_points(filepath:str ='./points.txt'):
    points = []
    with open (filepath , 'r') as myfile:
        for line_num, line in enumerate(myfile,start= 1):
            coordinates = line.strip().split(',')
            if len(coordinates) != 3:
                print('Not enough values to unpack!!!')
                continue
            else:
                try:
                    x,y,z = float(coordinates[0]),float(coordinates[1]), float(coordinates[2])
                    point = [x,y,z]
                    points.append(point)
                except ValueError as err:
                    print(f'Dropping the line {line_num} for bad data')
                    continue        
    return points

points = read_points()
point_dic = {}
for i in range(len(points)):
    point_dic[f'point {i+1}'] = Point(points[i][0],points[i][1],points[i][2])


def declare_centers(points:list , k: int):
    indexes = random.sample(range(len(points)),k)
    centers = [points[i] for i in indexes]
    return centers

def creating_clusters(points: list, centers: list, distance_method = 'euclidean'):
    clusters = []
    if distance_method == 'euclidean':
        for point in points:
            distances = [euclidean_distance(point1=point,point2=center) for center in centers]
            cluster = distances.index(min(distances))
            clusters.append(cluster)
    elif distance_method == 'manhatan':
        for point in points:
            distances = [manhatan_distance(point1=point,point2=center) for center in centers]
            cluster = distances.index(min(distances))
            clusters.append(cluster)

    return clusters

def center_update(points:list, clusters: list, k: int):
    new_centers = []
    for i in range(k):
        cluster_points = [points[j] for j in range(len(points)) if j==i]
        if cluster_points:
            new_center = tuple(sum(x) / len(cluster_points) for x in zip(*cluster_points))
            new_centers.append(new_center)
    return new_centers

def k_means(points: list, k: int, distance_method = 'euclidean'):
    centers = declare_centers(points, k)
    while True:
        clusters = creating_clusters(points, centers, distance_method)
        new_centers = center_update(points, clusters, k)
        if new_centers == centers:
            break
        else:
            centers = new_centers
    return clusters, centers


try:
    number_of_clusters = int(input('Please enter the number of clusters: '))
except ValueError as err:
    print('Only integer values are allowed')

while True:
    distance_method = int(input('How this program should calculate distance, enter 1 for  Euclidean "\n" or 2 for Manhatan: '))
    if not isinstance(distance_method,int):
        print('Only integer values are allowed.')
    else:
        if distance_method not in (1,2):
            print('Vailed Values are 1 for Euclidean and 2 for Manhatan ')
        else:
            break

if distance_method == 1:
    distance_method = 'euclidean'
else:
    distance_method = 'manhatan'


clusters, centers  =  k_means(points, number_of_clusters, distance_method)
print(clusters)
print(centers)











    







