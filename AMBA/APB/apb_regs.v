module apb_regs  #(		// 파라미터화된 APB 레지스터 모듈
	parameter	DW=32, 	// 데이터 폭(Data Width), 기본값은 32비트
	parameter	AW=5	// 주소 폭(Address Width), 기본값은 5비트
)(    
   input             	pclk,            // APB 클럭 신호
   input			 	presetn,         // 비동기 리셋 신호 (Low-active)
   
   input      [AW-1:0] 	paddr,           // APB 주소 버스
   input             	psel,            // 선택 신호 (슬레이브 선택 시 활성화)
   input             	penable,         // 활성화 신호 (전송 단계 확인)
   input             	pwrite,          // 쓰기 동작 여부 (쓰기 시 1, 읽기 시 0)
   output            	pready,          // 슬레이브가 준비되었음을 나타내는 신호
   input	  [DW-1:0] 	pwdata,          // 쓰기 데이터 버스 (APB에서 슬레이브로 전달)
   output reg [DW-1:0] 	prdata,          // 읽기 데이터 버스 (슬레이브에서 APB로 전달)
   output            	pslverr,         // 슬레이브 에러 신호

   // Interface - 제어 및 상태 레지스터 인터페이스
   input      [31:0] 	status32,        // 32비트 상태 레지스터 입력
   input      [15:0] 	status16,        // 16비트 상태 레지스터 입력
   input      [ 7:0] 	status8,         // 8비트 상태 레지스터 입력
   output reg [31:0] 	control32,       // 32비트 제어 레지스터 출력
   output reg [15:0] 	control16,       // 16비트 제어 레지스터 출력
   output reg [ 7:0] 	control8         // 8비트 제어 레지스터 출력
);

// 쓰기 동작 신호 생성
// psel (슬레이브 선택), penable (활성화), pwrite (쓰기 신호)가 모두 활성화될 때 쓰기 동작이 발생함을 나타냄
	wire apb_write = psel & penable & pwrite;
	
// 읽기 동작 신호 생성
// psel (슬레이브 선택), pwrite (읽기 신호)가 0일 때 읽기 동작이 발생함을 나타냄
	wire apb_read  = psel & ~pwrite;

// 슬레이브가 항상 준비됨을 나타내는 신호 (pready는 항상 1로 설정됨)
	assign pready  = 1'b1;

// 슬레이브 에러는 발생하지 않음 (pslverr는 항상 0으로 설정됨)
	assign pslverr = 1'b0;

// 제어 레지스터 쓰기 로직
// pclk 상승 에지 또는 presetn 하강 에지에서 동작
// 리셋 시 모든 제어 레지스터는 0으로 초기화됨
	always @(posedge pclk or negedge presetn)
	if (!presetn)	begin
		control32 <= 0;  // 리셋 시 control32 레지스터를 0으로 초기화
		control16 <= 0;  // 리셋 시 control16 레지스터를 0으로 초기화
		control8  <= 0;  // 리셋 시 control8 레지스터를 0으로 초기화
	end 
	// 쓰기 동작일 경우, paddr에 따라 각 제어 레지스터에 pwdata 값을 저장
	else if  (apb_write)	begin
		case (paddr)
		// 5'h00은 식별 레지스터 (Identification)으로 사용할 수 있음
		5'h04 : control32 <= pwdata;          // 5'h04 주소에 쓰기 시 control32에 pwdata 저장
		5'h08 : control16 <= pwdata[15:0];    // 5'h08 주소에 쓰기 시 control16에 pwdata의 하위 16비트를 저장
		5'h0C : control8  <= pwdata[7:0];     // 5'h0C 주소에 쓰기 시 control8에 pwdata의 하위 8비트를 저장
		// 5'h10은 예약됨 (Reserved)
		// 5'h14, 5'h18, 5'h1C는 읽기 전용 상태 레지스터 주소임
		endcase
	end

// 읽기 동작 시 데이터 반환 로직
// pclk 상승 에지 또는 presetn 하강 에지에서 동작
// 리셋 시 prdata는 0으로 초기화됨
	always @(posedge pclk or negedge presetn)
	if (!presetn)	begin	
		prdata	<= 0;   // 리셋 시 prdata를 0으로 초기화
	end 
	// 읽기 동작일 경우, paddr에 따라 prdata에 적절한 값을 할당
	else if (apb_read) begin
		case (paddr)
		5'h00 : prdata <= 'h12345678;         // 5'h00 주소 읽기 시 고정된 값 반환 (예: 식별 값)
		5'h04 : prdata <= control32;          // 5'h04 주소 읽기 시 control32 값을 반환
		5'h08 : prdata <= {16'h0, control16}; // 5'h08 주소 읽기 시 control16 값을 상위 16비트 0과 함께 반환
		5'h0C : prdata <= {24'h0, control8};  // 5'h0C 주소 읽기 시 control8 값을 상위 24비트 0과 함께 반환
		// 5'h10은 예약됨 (Reserved)
		5'h14 : prdata <= status32;           // 5'h14 주소 읽기 시 상태 레지스터 status32 값을 반환
		5'h18 : prdata <= {16'h0, status16};  // 5'h18 주소 읽기 시 status16 값을 상위 16비트 0과 함께 반환
		5'h1C : prdata <= {24'h0, status8};   // 5'h1C 주소 읽기 시 status8 값을 상위 24비트 0과 함께 반환
		default: prdata <= 0;                 // 정의되지 않은 주소에서는 기본값 0을 반환
		endcase
	end 
	
endmodule

