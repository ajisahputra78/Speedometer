//
//  ContentView.swift
//  Speedometer
//
//  Created by Aji_sahputra on 16/11/20.
//

import SwiftUI

struct ContentView: View {
  
  @State private var value = 25.0 //nilai default Speedometer
  
    var body: some View {
      ZStack {
        Color.black
        VStack {
          GaugeView(coveredRadius: 225, maxValue: 100, steperSplit: 10, value: $value)
          Slider(value: $value, in: 0...100, step: 1)
            .padding(.horizontal, 20)
            .accentColor(.orange)
          HStack {
            Spacer()
            Button(action: {
              self.value = 0
            }) {
              Text("Zero")
                .bold()
            }.foregroundColor(.green)
            Spacer()
            Button(action: {
              self.value = 100
            }) {
              Text("MAx")
                .bold()
            }.foregroundColor(.red)
            Spacer()
          }
        }
      }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct Needle: Shape { //membuat bentuk jarum merah
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: 0, y: rect.height / 2))
    path.addLine(to: CGPoint(x: rect.width, y: 0))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height))
    return path
  }
}

struct GaugeView: View {
  func colorMix(percent: Int) -> Color {
    let p = Double(percent) //dapatkan persen dan ubah menjadi dua kali lipat untuk desimal (akurasi)
    let tempG = (100.0 - p) / 100 //semakin banyak nilai p, semakin sedikit warna hijau yang akan diterapkan ke dalam campuran
    let g : Double = tempG < 0 ? 0 : tempG // terapkan nilai hijau saat tempG tidak kurang dari 0
    let tempR =  1 + (p - 100.0) / 100.0 //semakin tinggi nilai p, semakin banyak warna merah yang akan diaplikasikan ke dalam campuran
    let r : Double = tempR < 0 ? 0: tempR //terapkan nilai merah jika tampR tidak kurang dari 0
    return Color.init(red: r, green: g, blue: 0) //buat campuran warna dengan nilai yang diperoleh
  }
  
  func tick(at tick: Int, totalTicks: Int) -> some View { //fungsi mengatur tanda hubung kecil dan besar seperti di Speedometer
    let percent = (tick * 100) / totalTicks //dapatkan persen untuk campuran warna
    let starAngle = coveredRadius / 2 * -1
    let stepper = coveredRadius / Double(totalTicks) //jika 0 hingga 100 di langkah 10, itu akan ditampilkan 0, 10, 20,...,100
    let rotation = Angle.degrees(starAngle + stepper * Double(tick)) //dapatkan sudut rotasi dalam derajat menggunakan start angle, stepper, and tick
    return VStack { // VStack yang memutar pandangannya dengan rotationEffect
      Rectangle()
        .fill(colorMix(percent: percent))
        .frame(width: tick % 2 == 0 ? 5 : 3, height: tick % 2 == 0 ? 20 : 10) //beralih antara tanda hubung kecil dan besar
      Spacer()
    }.rotationEffect(rotation)
  }
  
  func tickText(at tick: Int, text: String) -> some View {
    let percent = (tick * 100) / tickCount // dapatkan persentase untuk menerapkan campuran warna
    let startAngle = coveredRadius / 2 * -1 + 90 //dapatkan sstart angle untuk referensi tentang rotasi
    let stepper = coveredRadius / Double(tickCount) //jumlah spasi di antara setiap nilai teks
    let rotation = startAngle + stepper * Double(tick) //menghitung rotasi
    return Text(text).foregroundColor(colorMix(percent: percent)).rotationEffect(.init(degrees: -1 * rotation), anchor: .center).offset(x: -110, y: 0).rotationEffect(Angle.degrees(rotation)) //atur nilai teks dengan nilai rotasi yang sesuai dan offset nilai x agar sejajar dengan tanda hubung
  }
  
  let coveredRadius : Double //0 -360
  let maxValue : Int
  let steperSplit : Int
  
  private var tickCount: Int {
    return maxValue / steperSplit
  }
  
  @Binding var value: Double
  
  var body: some View {
    ZStack {
      Text("\(value, specifier: "%0.0f")") //untuk nilai speedometer ditunjukkan di tengah
        .font(.system(size: 40, weight: Font.Weight.bold))
        .foregroundColor(Color.orange)
        .offset(x: 0, y: 40)
      ForEach(0..<tickCount * 2 + 1) { tick in //loop ini mengatur garis putus-putus
        self.tick(at: tick, totalTicks: self.tickCount * 2)
      }
      ForEach(0..<tickCount + 1) { tick in // loop ini mengatur nilai seperti : 0, 10, 20, ... di sekitar speedometer
        self.tickText(at: tick, text: "\(self.steperSplit * tick)")
      }
      Needle() //jarum merah mengarahkan kecepatan
        .fill(Color.red)
        .frame(width: 140, height: 6)
        .offset(x: -70, y: 0)
        .rotationEffect(.init(degrees: getAngle(value: value)), anchor: .center) //dapatkan nilai yang ditetapkan di tampilan utama
        .animation(.linear)
      Circle() //titik rotasi jarum, lingkaran sederhana
        .frame(width: 20, height: 20)
        .foregroundColor(.red)
    }.frame(width: 300, height: 300, alignment: .center) //bingkai pengukur
  }
  
  func getAngle(value: Double) -> Double { //fungsi yang mendapatkan sudut dengan nilai yang ditentukan dan menyetelnya ke jarum
    return (value / Double(maxValue)) * coveredRadius - coveredRadius / 2 + 90
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
