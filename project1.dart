import 'dart:io';

// 상품 클래스 정의
class Product {
  String name;     // 상품 이름
  int price;       // 상품 가격

  // 생성자
  Product(this.name, this.price);
}

// 쇼핑몰 클래스 정의
class ShoppingMall {
  List<Product> products = [];    // 판매하는 상품 목록
  int totalPrice = 0;             // 장바구니에 담은 상품들의 총 가격

  // 생성자: 상품 목록 초기화
  ShoppingMall() {
    products.add(Product('셔츠', 45000));
    products.add(Product('원피스', 30000));
    products.add(Product('반팔티', 35000));
    products.add(Product('반바지', 38000));
    products.add(Product('양말', 5000));
  }

  // 상품 목록을 출력하는 메서드
  void showProducts() {
    print('\n----- 상품 목록 -----');
    for (var product in products) {
      print('${product.name} / ${product.price}원');
    }
    print('---------------------\n');
  }

  // 상품을 장바구니에 담는 메서드
  void addToCart() {
    print('\n장바구니에 담을 상품 이름을 입력하세요:');
    String? productName = stdin.readLineSync();
    
    // 상품 이름이 목록에 있는지 확인
    bool productExists = false;
    Product? selectedProduct;
    
    for (var product in products) {
      if (product.name == productName) {
        productExists = true;
        selectedProduct = product;
        break;
      }
    }
    
    if (!productExists) {
      print('입력값이 올바르지 않아요!');
      return;
    }
    
    print('장바구니에 담을 상품 개수를 입력하세요:');
    String? countInput = stdin.readLineSync();
    
    try {
      int count = int.parse(countInput!);
      
      if (count <= 0) {
        print('0개보다 많은 개수의 상품만 담을 수 있어요!');
        return;
      }
      
      // 장바구니에 상품 추가
      totalPrice += selectedProduct!.price * count;
      print('장바구니에 상품이 담겼어요!');
      
    } catch (e) {
      print('입력값이 올바르지 않아요!');
    }
  }

  // 장바구니에 담은 상품의 총 가격을 출력하는 메서드
  void showTotal() {
    print('\n장바구니에 ${totalPrice}원 어치를 담으셨네요!');
  }
}

void main() {
  // 쇼핑몰 인스턴스 생성
  ShoppingMall shoppingMall = ShoppingMall();
  bool isRunning = true;
  
  // 프로그램 실행
  while (isRunning) {
    print('\n[1] 상품 목록 보기 / [2] 장바구니에 담기 / [3] 장바구니에 담긴 상품의 총 가격 보기 / [4] 프로그램 종료');
    print('원하는 기능의 번호를 입력하세요:');
    
    String? input = stdin.readLineSync();
    
    switch (input) {
      case '1':
        shoppingMall.showProducts();
        break;
      case '2':
        shoppingMall.addToCart();
        break;
      case '3':
        shoppingMall.showTotal();
        break;
      case '4':
        print('\n이용해 주셔서 감사합니다.');
        isRunning = false;
        break;
      default:
        print('\n구현되지 않은 기능입니다.');
    }
  }
}
