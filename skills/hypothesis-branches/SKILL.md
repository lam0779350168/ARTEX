---
name: hypothesis-branches
description: "Sinh nhiều giả thuyết cạnh tranh từ dữ liệu vừa nhận được, kèm dự đoán phân biệt và cách bác bỏ; không coi giả thuyết là bằng chứng."
capabilities: [recon.active, scan.vuln, exploit, code-audit]
tools_required: [record_fact, list_assets, traffic_search]
---
# Sinh nhiều nhánh giả thuyết

Biến một quan sát thành tập giả thuyết đối thủ, rồi chọn phép thử phân biệt được chúng. Giả thuyết là đề xuất để thử và bác bỏ — không phải kết luận, không phải finding, không phải dữ kiện đã xác nhận.

Nguồn: chuyển thể từ repo `k-dense-ai/scientific-agent-skills` (skill `hypothesis-generation`, MIT). Bản gốc tiếng Anh được lưu tại `references/original-SKILL.md`.

## Khi nào dùng
Dùng khi dữ liệu thu được cho thấy một dấu hiệu nhưng nguyên nhân chưa rõ: phản hồi bất thường, fingerprint mâu thuẫn, tham số có vẻ dễ tổn thương, lỗi bảo mật không lặp lại, hoặc cần explore nhiều hướng trước khi quyết định gọi tool tiếp theo. Không dùng để hợp thức hóa một kết luận đã có sẵn.

## Capabilities yêu cầu
- recon.active
- scan.vuln
- exploit
- code-audit

## Tools yêu cầu
- record_fact
- list_assets
- traffic_search

Phân giải theo capability: worker ánh xạ capability tới tool đã đăng ký trong runtime. Skill này không khai báo tên server cố định. Khi cần tool ngoài nhóm trên, dùng `SearchExtraTools` để tìm và `ExecuteExtraTool` để gọi.

## Quy trình ngắn

1. **Đóng băng quan sát.** Ghi lại nguồn, thời điểm, phạm vi, đơn vị quan sát, dữ liệu thiếu và độ bất định. Dùng từ "quan sát được", "được báo cáo", "tương quan" — không dùng từ nhân quả khi chưa có thiết kế kiểm chứng. Lưu qua `record_fact` với `confidence=observed` hoặc `inferred` cho phù hợp.
2. **Đặt câu hỏi trả lời được.** Giới hạn đối tượng, điều kiện, kết quả cần phân biệt và ranh giới ủy quyền.
3. **Sinh các nhánh đối thủ trước khi chọn test.** Ít nhất các lớp khác nhau sau, nếu có thể: cơ chế ứng dụng thật; lỗi công cụ/đo lường; cấu hình hoặc bộ lọc trung gian; thiên kiến chọn mẫu/phạm vi; nhân quả ngược; biến động ngẫu nhiên. Gắn nhãn mọi ý là `candidate`; đừng ép số lượng hay tạo đối xứng giả.
4. **Viết dự đoán phân biệt cho từng nhánh.** Nêu điều kiện, tín hiệu quan sát được, kết quả mong đợi, kết quả nào sẽ bác bỏ nhánh, và nhánh đối thủ dự đoán gì khác đi. Ưu tiên phép thử mà các nhánh cho kết quả khác nhau rõ rệt.
5. **Chạy phép thử có thông tin nhất.** Kiểm tra deadline và scope trước; nếu cần tool đã defer, dùng `SearchExtraTools`/`ExecuteExtraTool`. Đối chiếu thêm với `list_assets` và `traffic_search` để tránh lặp dữ liệu đã có.
6. **Cập nhật trạng thái trung thực.** `chưa kiểm chứng` / `bị bác bỏ` / `được ủng hộ nhưng chưa chắc chắn` — không viết thành "đã xác nhận". Chỉ `report_finding` khi có PoC thực thi được và bằng chứng tái tạo được; nếu không, ghi `record_fact` dạng inferred để planner tiếp tục.

## Ranh giới không được vượt
- Không trình bày giả thuyết, cơ chế, suy luận nhân quả hay "pattern thấy được" như bằng chứng.
- Không suy nhân quả chỉ từ tương quan, trình tự thời gian, độ chính xác dự báo hoặc output của mô hình.
- Không bịa nguồn, ID, phạm vi tìm kiếm, kết quả hay sự phê duyệt.
- Không tự động xếp hạng/chọn/chấp nhận một giả thuyết thay cho con người.
- Dừng lại ở cổng phê duyệt/scope: nếu dữ liệu nằm ngoài ủy quyền hoặc vượt giới hạn nhạy cảm, chỉ báo phần risk ở mức cao và chuyển cho operator.

## End-to-end test case
Với một target nằm trong scope và các tool ở trên đã đăng ký, đưa cho worker một quan sát mâu thuẫn (ví dụ: response `403` nhưng fingerprint cho thấy framework cũ). Yêu cầu sinh ít nhất ba nhánh giả thuyết thuộc lớp khác nhau, mỗi nhánh có dự đoán phân biệt và điều kiện bác bỏ; kiểm tra transcript có gọi `Skill` với tên skill này, có ít nhất một `record_fact` mang `confidence=inferred`, không có `report_finding` nào được tạo chỉ từ giả thuyết, và mọi kết quả tool dùng đúng record `{target, status, findings[], raw_ref}`.
